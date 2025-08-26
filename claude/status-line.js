#!/usr/bin/env node

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, statSync } from 'fs';
import { execSync } from 'child_process';
import { basename } from 'path';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function logStatusLine(inputData, statusLineOutput) {
    const logDir = 'logs';
    
    // Ensure logs directory exists
    if (!existsSync(logDir)) {
        mkdirSync(logDir, { recursive: true });
    }
    
    const logFile = join(logDir, 'status_line.json');
    
    // Read existing log data or initialize empty array
    let logData = [];
    if (existsSync(logFile)) {
        try {
            const fileContent = readFileSync(logFile, 'utf8');
            logData = JSON.parse(fileContent);
        } catch (error) {
            logData = [];
        }
    }
    
    // Create log entry with input data and generated output
    const logEntry = {
        timestamp: new Date().toISOString(),
        input_data: inputData,
        status_line_output: statusLineOutput
    };
    
    // Append the log entry
    logData.push(logEntry);
    
    // Write back to file with formatting
    writeFileSync(logFile, JSON.stringify(logData, null, 2));
}

function getGitBranch() {
    try {
        const result = execSync('git rev-parse --abbrev-ref HEAD', { 
            encoding: 'utf8', 
            timeout: 2000,
            stdio: ['pipe', 'pipe', 'pipe']
        });
        return result.trim();
    } catch (error) {
        return null;
    }
}

function getGitStatus() {
    try {
        const result = execSync('git status --porcelain', { 
            encoding: 'utf8', 
            timeout: 2000,
            stdio: ['pipe', 'pipe', 'pipe']
        });
        const changes = result.trim();
        if (changes) {
            const lines = changes.split('\n');
            return `±${lines.length}`;
        }
    } catch (error) {
        // Ignore errors
    }
    return "";
}


function generateStatusLine(inputData) {
    const parts = [];
    
    // Current directory
    const workspace = inputData.workspace || {};
    const currentDir = workspace.current_dir || '';
    if (currentDir) {
        const dirName = basename(currentDir);
        parts.push("\x1b[38;5;10m❯ " + dirName + "\x1b[0m"); // Bright green (color 10)
    }
    
    // Git branch and status
    const gitBranch = getGitBranch();
    if (gitBranch) {
        const gitStatus = getGitStatus();
        let gitInfo = "⌥ " + gitBranch;
        if (gitStatus) {
            gitInfo += " " + gitStatus;
        }
        parts.push("\x1b[38;5;5m" + gitInfo + "\x1b[0m"); // Magenta (color 5)
    }
    
    // Version info (optional, smaller)
    const version = inputData.version || '';
    if (version) {
        parts.push("\x1b[90mv" + version + "\x1b[0m"); // Gray color
    }
    
    // Model display name
    const modelInfo = inputData.model || {};
    const modelName = modelInfo.display_name || 'Claude';
    parts.push("\x1b[90m[" + modelName + "]\x1b[0m"); // Gray color
    
    return parts.join(" | ");
}

function main() {
    try {
        // Read JSON input from stdin
        let input = '';
        
        if (process.stdin.isTTY) {
            // No input from stdin, exit gracefully
            console.log("\x1b[31m❯ [Claude] No Input\x1b[0m");
            process.exit(0);
        }
        
        process.stdin.setEncoding('utf8');
        
        process.stdin.on('readable', () => {
            let chunk;
            while (null !== (chunk = process.stdin.read())) {
                input += chunk;
            }
        });
        
        process.stdin.on('end', () => {
            try {
                const inputData = JSON.parse(input);
                
                // Generate status line
                const statusLine = generateStatusLine(inputData);
                
                // Log the status line event
                logStatusLine(inputData, statusLine);
                
                // Output the status line (first line of stdout becomes the status line)
                console.log(statusLine);
                
                // Success
                process.exit(0);
            } catch (jsonError) {
                // Handle JSON decode errors gracefully - output basic status
                console.log("\x1b[31m❯ [Claude] Unknown\x1b[0m");
                process.exit(0);
            }
        });
        
    } catch (error) {
        // Handle any other errors gracefully - output basic status
        console.log("\x1b[31m❯ [Claude] Error\x1b[0m");
        process.exit(0);
    }
}

if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}