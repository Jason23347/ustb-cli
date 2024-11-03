# ustb-cli

一个Linux环境下的北科大校园网工具箱。

## Build

使用`./merge.sh [SCRIPT_NAME] [MODULES...]`生成你的自定义脚本。
例如
```bash
./merge.sh ustb-cli account balance # without clock
```
将生成一个有account和balance模块的脚本，并且没有clock模块。

## Usage

运行指令
```bash
ustb-cli login
```

CLI模式
```
ustb-cli
ustb> help
Usage: ustb-cli [options] <command>
Commands:
login		login to USTB web
logout		logout of USTB web
whoami		show current user
fee		show network fees left
info		show further flow information
version		show version and authors
help		show this information

ustb>
```

## Customize

脚本开头定义了一些选项。

## 许可

本项目遵循MIT许可证。
This project is under MIT license.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
