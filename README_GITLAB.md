# GitLab Token & DDEV Secure Bridge

This script automates the secure storage and propagation of a GitLab **Personal Access Token (PAT)** from your host machine's OS-level vault (Keychain/Keyring) into your **DDEV** development containers.

## 🎯 Purpose

By default, developers often hardcode tokens in `.zshrc` or `.npmrc` files. This is a security risk. This setup:

1. **Encrypts** the token using your OS's native security tools.
2. **Prevents** tokens from being committed to Git (no plain-text tokens in project files).
3. **Syncs** your credentials automatically across all DDEV projects via global configuration.

---

## 🛠 How it Works

The flow of the token follows this path: **macOS Keychain/Linux Keyring** → **Shell Environment Variable** → **DDEV Web Service** → **NPM/Composer**

### 1. Secure Storage

Instead of a text file, the script saves your token in:

* **macOS:** Keychain (via `security` CLI).
* **Linux:** Secret Service API (via `secret-tool`).

### 2. Shell Integration

The script adds a dynamic lookup to your `~/.zshrc`. Every time you open a terminal, it runs a command to fetch the token from the vault and stores it in the `PERSONAL_ACCESS_TOKEN` variable.

### 3. DDEV Global Passthrough

DDEV is configured globally (`~/.ddev/global_config.yaml`) to "pass through" this host variable into the `web` container.

### 4. Package Manager Configuration

The script populates `~/.ddev/homeadditions/` with template files. When a DDEV project starts, these files are mapped into the container's home directory:

* **`.npmrc`**: Configured to use the variable for GitLab Registry authentication.
* **`auth.json`**: Configured to use the variable for Composer GitLab authentication.

---

## 🚀 Setup Instructions

### Prerequisites

* **macOS:** No extra tools needed.
* **Linux:** Requires `libsecret-tools` (e.g., `sudo apt install libsecret-tools`).
* **DDEV:** Must be installed on your host.

### Execution

1. Save the provided `setup-gitlab.sh` script to your machine.
2. Make it executable:
   **Bash**

   ```
   chmod +x setup-gitlab.sh
   ```
3. Run the script:
   **Bash**

   ```
   ./setup-gitlab.sh
   ```
4. **Restart your terminal** or run `source ~/.zshrc`.
5. **Restart DDEV** for any running projects:
   **Bash**

   ```
   ddev restart
   ```

---

## 📂 File Structure Created

The script will manage the following files:


| File Location                               | Purpose                                         |
| ------------------------------------------- | ----------------------------------------------- |
| `~/.zshrc`                                  | Fetches the token from the OS vault at startup. |
| `~/.ddev/global_config.yaml`                | Maps the host variable to the Docker container. |
| `~/.ddev/homeadditions/.npmrc`              | Global template for NPM auth.                   |
| `~/.ddev/homeadditions/.composer/auth.json` | Global template for Composer auth.              |

In Google Sheets exportieren

---

## 🔐 Security Note

Because we use the `${VARIABLE}` syntax inside the `.npmrc` and `auth.json` files, the **actual token is never written to these files.** They only contain a reference to the environment variable, which exists only in memory while the container is running.
