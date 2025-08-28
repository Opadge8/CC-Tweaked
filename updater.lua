-- /personalOS/updater.lua
 
-- CONFIG: set your GitHub repo info
local githubUser   = "Opadge8"       -- your GitHub username
local githubRepo   = "CC-Tweaked"           -- repo name
local branch       = "main"           -- branch name
 
-- List of files to update: path in repo => local path
local files = {
    ["updater.lua"] = "/personalOS/updater.lua",
    ["config.lua"] = "/personalOS/config.lua",
    ["init.lua"] = "/personalOS/init.lua",
    --["apps/factory.lua"] = "/personalOS/apps/factory.lua",
    --["apps/files.lua"] = "/personalOS/apps/files.lua",
    --["apps/notes.lua"] = "/personalOS/apps/notes.lua",
    --["apps/clock.lua"] = "/personalOS/apps/clock.lua",
    --["apps/run.lua"] = "/personalOS/apps/run.lua",
    --["apps/settings.lua"] = "/personalOS/apps/settings.lua",
}
 
-- Enable HTTP API
if not http then
    error("HTTP API is not enabled. Run /enable http in CC:Tweaked.")
end
 
-- Helper to download a file
local function downloadFile(url, path)
    print("Fetching "..url.." -> "..path)
    local resp = http.get(url)
    if not resp then
        print("Failed to fetch "..url)
        return false
    end
    local content = resp.readAll()
    resp.close()
 
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
    return true
end
 
-- Ensure directories exist
for _, path in pairs(files) do
    local dir = fs.getDir(path)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
end
 
-- Download all files
for repoPath, localPath in pairs(files) do
    local url = "https://raw.githubusercontent.com/"..githubUser.."/"..githubRepo.."/"..branch.."/"..repoPath
    local ok = downloadFile(url, localPath)
    if not ok then
        print("Warning: Failed to update "..localPath)
    end
end
 
print("\nUpdate complete! Running PersonalOS...\n")
sleep(1)
shell.run("/personalOS/init.lua")