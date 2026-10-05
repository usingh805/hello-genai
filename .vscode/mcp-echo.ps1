$ErrorActionPreference = 'Stop'

function Write-JsonRpcMessage {
    param([hashtable]$Message)

    $json = ConvertTo-Json -InputObject $Message -Compress -Depth 100
    [Console]::Out.WriteLine($json)
}

function Write-JsonRpcError {
    param(
        [object]$Id,
        [int]$Code,
        [string]$Message
    )

    Write-JsonRpcMessage @{ jsonrpc = '2.0'; id = $Id; error = @{ code = $Code; message = $Message } }
}

while ($null -ne ($line = [Console]::In.ReadLine())) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    try {
        $request = ConvertFrom-Json -InputObject $line -AsHashtable
    }
    catch {
        Write-JsonRpcError -Id $null -Code -32700 -Message 'Parse error'
        continue
    }

    $hasId = $request.ContainsKey('id')
    $requestId = if ($hasId) { $request['id'] } else { $null }
    $method = $request['method']
    $params = $request['params']

    if (-not $hasId) {
        continue
    }

    switch ($method) {
        'initialize' {
            $requestedVersion = $params['protocolVersion']
            if ([string]::IsNullOrWhiteSpace($requestedVersion)) {
                $requestedVersion = '2025-06-18'
            }

            $result = @{
                protocolVersion = $requestedVersion
                capabilities = @{ tools = @{} }
                serverInfo = @{ name = 'echo-mac'; version = '1.0.0' }
            }
            Write-JsonRpcMessage @{ jsonrpc = '2.0'; id = $requestId; result = $result }
        }
        'ping' {
            Write-JsonRpcMessage @{ jsonrpc = '2.0'; id = $requestId; result = @{} }
        }
        'tools/list' {
            $tool = @{
                name = 'echo'
                description = 'Return the supplied text unchanged.'
                inputSchema = @{
                    type = 'object'
                    properties = @{ text = @{ type = 'string'; description = 'Text to echo.' } }
                    required = @('text')
                }
            }
            Write-JsonRpcMessage @{ jsonrpc = '2.0'; id = $requestId; result = @{ tools = @($tool) } }
        }
        'tools/call' {
            if ($params['name'] -ne 'echo') {
                Write-JsonRpcMessage @{
                    jsonrpc = '2.0'
                    id = $requestId
                    result = @{ content = @(@{ type = 'text'; text = "Unknown tool: $($params['name'])" }); isError = $true }
                }
                continue
            }

            $text = $params['arguments']['text']
            if ($null -eq $text) {
                $text = ''
            }

            Write-JsonRpcMessage @{
                jsonrpc = '2.0'
                id = $requestId
                result = @{ content = @(@{ type = 'text'; text = [string]$text }) }
            }
        }
        default {
            Write-JsonRpcError -Id $requestId -Code -32601 -Message "Method not found: $method"
        }
    }
}