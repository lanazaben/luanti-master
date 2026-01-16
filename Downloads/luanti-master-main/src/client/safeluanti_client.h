#pragma once
#include <string>

enum SafeLuantiDecision {
    ALLOW,
    BLOCK,
    FLAG
};

class SafeLuantiClient {
public:
    static SafeLuantiDecision inspectMessage(
        const std::string &sender,
        const std::string &message
    );
};
