class QwenTransformer {
    constructor(options) {
        this.options = options;
        this.name = "qwen-transformer";
    }

    async transformRequestIn(req) {
        // 1. Rename WebSearch to web_search in tools
        if (Array.isArray(req.tools)) {
            req.tools = req.tools.map(tool => {
                if (tool.function && (tool.function.name === "WebSearch" || tool.function.name === "web_search")) {
                    // Qwen models prefer 'web_search' and need a clear definition
                    return {
                        ...tool,
                        function: {
                            ...tool.function,
                            name: "web_search",
                            description: "Search the web for real-time information using Qwen's search engine.",
                            parameters: {
                                type: "object",
                                properties: {
                                    query: {
                                        type: "string",
                                        description: "The search query to look up on the web."
                                    }
                                },
                                required: ["query"]
                            }
                        }
                    };
                }
                return tool;
            });
        }

        // Adjust system prompt to be more Qwen-friendly
        let systemReminder = "\n[System Reminder]: You have access to a `web_search` tool. Use it if you need real-time information from the web. If you decide to search, call the `web_search` tool.";

        if (Array.isArray(req.system)) {
            req.system.push({
                type: "text",
                text: systemReminder
            });
        } else if (typeof req.system === "string") {
            req.system += systemReminder;
        } else if (req.system && typeof req.system === "object") {
            // Handle single text block system prompt if it exists
            if (req.system.text) {
                req.system.text += systemReminder;
            }
        }

        return req;
    }

    async transformResponseOut(res) {
        const contentType = res.headers.get("Content-Type") || "";

        if (contentType.includes("application/json")) {
            try {
                const body = await res.json();
                let changed = false;

                if (body.choices?.[0]?.message?.tool_calls) {
                    body.choices[0].message.tool_calls = body.choices[0].message.tool_calls.map(tc => {
                        // Map both variations back to web_search (as expected by newer Claude CLI)
                        if (tc.function && (tc.function.name === "web_search" || tc.function.name === "WebSearch")) {
                            tc.function.name = "web_search";
                            changed = true;
                        }
                        return tc;
                    });
                }

                if (changed) {
                    return new Response(JSON.stringify(body), {
                        status: res.status,
                        statusText: res.statusText,
                        headers: res.headers
                    });
                }

                // Re-wrap the body if we read it but didn't change it
                return new Response(JSON.stringify(body), {
                    status: res.status,
                    statusText: res.statusText,
                    headers: res.headers
                });
            } catch (e) {
                return res;
            }
        }

        // For streaming responses, we need to handle the renaming in the stream
        if (contentType.includes("text/event-stream")) {
            const reader = res.body.getReader();
            const encoder = new TextEncoder();
            const decoder = new TextDecoder();
            let buffer = "";

            const stream = new ReadableStream({
                async start(controller) {
                    try {
                        while (true) {
                            const { done, value } = await reader.read();
                            if (done) break;

                            const chunk = decoder.decode(value, { stream: true });
                            buffer += chunk;

                            const lines = buffer.split("\n");
                            buffer = lines.pop();

                            for (const line of lines) {
                                if (line.startsWith("data: ")) {
                                    const dataStr = line.slice(6).trim();
                                    if (dataStr !== "[DONE]") {
                                        try {
                                            const data = JSON.parse(dataStr);
                                            // Check for tool call rename in delta
                                            if (data.choices?.[0]?.delta?.tool_calls) {
                                                data.choices[0].delta.tool_calls.forEach(tc => {
                                                    if (tc.function && (tc.function.name === "web_search" || tc.function.name === "WebSearch")) {
                                                        tc.function.name = "web_search";
                                                    }
                                                });
                                                controller.enqueue(encoder.encode(`data: ${JSON.stringify(data)}\n\n`));
                                                continue;
                                            }
                                        } catch (e) {
                                            // Not JSON or parse error, send as is
                                        }
                                    }
                                }
                                controller.enqueue(encoder.encode(line + "\n"));
                            }
                        }
                        controller.close();
                    } catch (e) {
                        controller.error(e);
                    }
                }
            });

            return new Response(stream, {
                status: res.status,
                statusText: res.statusText,
                headers: res.headers
            });
        }

        return res;
    }
}

module.exports = QwenTransformer;
