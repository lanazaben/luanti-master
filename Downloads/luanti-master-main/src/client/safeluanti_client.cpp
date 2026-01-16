#include "safeluanti_client.h"
#include "util/string.h"
#include "settings.h"
#include "log.h"
#include <json/json.h>
#include <sstream>

#ifdef _WIN32
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#define closesocket(s) ::closesocket(s)
#define SOCKET_ERR() WSAGetLastError()
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>
#include <cerrno>
#define closesocket(s) ::close(s)
#define SOCKET_ERR() errno
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1
typedef int SOCKET;
#endif

// Helper function to create TCP socket and connect
static bool tcp_connect(const std::string &host, int port, SOCKET &sock)
{
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) {
        return false;
    }

    // Set non-blocking mode for timeout
#ifdef _WIN32
    u_long mode = 1;
    ioctlsocket(sock, FIONBIO, &mode);
#else
    int flags = fcntl(sock, F_GETFL, 0);
    fcntl(sock, F_SETFL, flags | O_NONBLOCK);
#endif

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);

    // Resolve hostname
    struct hostent *he = gethostbyname(host.c_str());
    if (!he) {
        closesocket(sock);
        return false;
    }
    memcpy(&addr.sin_addr, he->h_addr_list[0], he->h_length);

    // Try to connect with timeout
    int result = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
    if (result == SOCKET_ERROR) {
#ifdef _WIN32
        int err = WSAGetLastError();
        if (err != WSAEWOULDBLOCK) {
            closesocket(sock);
            return false;
        }
#else
        if (errno != EINPROGRESS) {
            closesocket(sock);
            return false;
        }
#endif
        // Wait for connection with timeout (500ms)
        fd_set writefds;
        FD_ZERO(&writefds);
#ifdef _WIN32
        FD_SET(sock, &writefds);
#else
        FD_SET(sock, &writefds);
#endif
        struct timeval timeout;
        timeout.tv_sec = 0;
        timeout.tv_usec = 500000; // 500ms
#ifdef _WIN32
        result = select(0, nullptr, &writefds, nullptr, &timeout);
#else
        result = select(sock + 1, nullptr, &writefds, nullptr, &timeout);
#endif
        if (result <= 0) {
            closesocket(sock);
            return false;
        }
    }

    // Set back to blocking mode
#ifdef _WIN32
    mode = 0;
    ioctlsocket(sock, FIONBIO, &mode);
#else
    flags = fcntl(sock, F_GETFL, 0);
    fcntl(sock, F_SETFL, flags & ~O_NONBLOCK);
#endif

    return true;
}

// Helper function to send data
static bool tcp_send(SOCKET sock, const std::string &data)
{
    size_t total_sent = 0;
    while (total_sent < data.length()) {
        int sent = send(sock, data.c_str() + total_sent, data.length() - total_sent, 0);
        if (sent <= 0) {
            return false;
        }
        total_sent += sent;
    }
    return true;
}

// Helper function to receive line (until \n)
static bool tcp_receive_line(SOCKET sock, std::string &line, int timeout_ms = 500)
{
    line.clear();
    char buffer[1];
    // Set receive timeout
    struct timeval timeout;
    timeout.tv_sec = timeout_ms / 1000;
    timeout.tv_usec = (timeout_ms % 1000) * 1000;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(timeout));

    while (true) {
        int received = recv(sock, buffer, 1, 0);
        if (received <= 0) {
            return false;
        }
        if (buffer[0] == '\n') {
            return true;
        }
        if (buffer[0] != '\r') {
            line += buffer[0];
        }
    }
}

SafeLuantiDecision SafeLuantiClient::inspectMessage(
    const std::string &sender,
    const std::string &message)
{
    // Get backend host and port from settings (matching mod defaults)
    std::string host = g_settings->get("safeluanti_backend_host");
    if (host.empty()) {
        host = "127.0.0.1";
    }
    int port = g_settings->getS32("safeluanti_backend_port");
    if (port == 0) {
        port = 5050; // Default port matching mod
    }

    // Build JSON payload matching SafeLuanti mod format
    // The mod uses: {sender, message, childId}
    Json::Value root;
    root["sender"] = sender;
    root["message"] = message;
    // Use sender as childId for now (can be made configurable later)
    root["childId"] = sender;

    Json::StreamWriterBuilder writer;
    std::string json_payload = Json::writeString(writer, root);
    json_payload += "\n"; // Add newline like the mod does

    // Create TCP connection
    SOCKET sock = INVALID_SOCKET;
    if (!tcp_connect(host, port, sock)) {
        // Fail open (allow message) if backend is unavailable
        return ALLOW;
    }

    // Send message
    if (!tcp_send(sock, json_payload)) {
        closesocket(sock);
        return ALLOW; // Fail open
    }

    // Receive response
    std::string response_line;
    if (!tcp_receive_line(sock, response_line, 500)) {
        closesocket(sock);
        return ALLOW; // Fail open
    }

    closesocket(sock);

    // Parse JSON response: { "decision": "ALLOW" | "BLOCK" | "FLAG" } (uppercase, matching mod)
    Json::CharReaderBuilder reader;
    Json::Value response;
    std::string errs;

    std::istringstream ss(response_line);
    if (!Json::parseFromStream(reader, ss, &response, &errs)) {
        return ALLOW; // Fail open
    }

    std::string decision_str = response.get("decision", "ALLOW").asString();
    // Match uppercase format used by SafeLuanti mod
    if (decision_str == "BLOCK") {
        return BLOCK;
    } else if (decision_str == "FLAG") {
        return FLAG;
    }
    // Default to ALLOW (also handles "ALLOW" string)
    return ALLOW;
}
