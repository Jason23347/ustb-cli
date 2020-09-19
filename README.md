# ustb-cli
A utility bash script fro USTB web.

## Usage
To excute a command:
```bash
ustb-cli login
```

CLI mode:
```
ustb-cli
ustb> help
Usage: ustb-cli [options] <command>
Commands:
login           login to ustb wifi
whoami          show current user
fee             show network fees left
info            show further flow infomation
version         show version and authors
help            show this information

ustb>
```

Also, you can change the default settings at the beggining of the file:
```bash
# Or 202.204.48.66, login.ustb.edu.cn.
LOGIN_HOST=202.204.48.82
# 0 or 1, set to 0 if you want to get a
# confim message while getting ipv6
# address when login.
ALWAYS_ATTEMPT_IPV6=1
# 0 or 1, set to 0 if you want to input
# username for each login attempt
ALWAYS_USE_DEFAULT_USER=1
# a list of Wi-Fi ESSIDs, and you don't want to
# do login check when connected to one of these.
WIFI_SKIP_LOGIN="USTB-Student USTB-V6"
```

## Download
At first, clone this repo:
```bash
git clone https://github.com/Jason23347/ustb-cli.git
```
then move the script to a path in your global variable `$PATH`, e.g. /usr/bin.

**However**, a personal path (~/bin, ~/.local/bin) is recommended as you can manage your personalized exutables easily. Do the export at the start of your rc file (~/.bashrc, ~/.zshrc, etc.)
```bash
exoprt PATH=/your/path:$PATH
```

## Licence
This project is under MIT licence.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

# TODOs

- [x] colorize output
- [x] parse commands more flexibly