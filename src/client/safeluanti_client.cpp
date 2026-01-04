#include "safeluanti_client.h"
#include "httpfetch.h"
#include "util/string.h"
#include <json/json.h>
#include <sstream>

SafeLuantiDecision SafeLuantiClient::inspectMessage(
    const std::string &sender,
    const std::string &message)
{
    // Build JSON body matching SafeLuanti mod format
    // The mod uses: {sender, message, childId}
    Json::Value root;
    root["sender"] = sender;
    root["message"] = message;
    // Use sender as childId for now (can be made configurable later)
    root["childId"] = sender;

    Json::StreamWriterBuilder writer;
    std::string body = Json::writeString(writer, root);

    HTTPFetchRequest req;
    // Match the URL used by the SafeLuanti mod
    req.url = "http://localhost:3000/api/moderation/inspect";
    req.method = HTTP_POST;
    req.raw_data = body;
    req.extra_headers.emplace_back("Content-Type: application/json");
    req.timeout = 500; // 500ms timeout

    HTTPFetchResult res;
    // Note: This should ideally be called from a background thread
    // For now, we'll use a short timeout and fail-open if it doesn't work
    bool completed = httpfetch_sync_interruptible(req, res, 50);

    if (!completed || !res.succeeded || res.response_code != 200) {
        // Fail open (allow message) if backend is unavailable
        return ALLOW;
    }

    // Parse JSON response: { "decision": "ALLOW" | "BLOCK" | "FLAG" } (uppercase, matching mod)
    Json::CharReaderBuilder reader;
    Json::Value response;
    std::string errs;

    std::istringstream ss(res.data);
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
