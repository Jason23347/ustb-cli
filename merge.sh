#!/bin/bash
# This is a script tp merge all the modules.

load_module() {
	local mod_file="modules/$1.sh"
	[ -f "$mod_file" ] || {
		echo "Cannot find module: ${mod:-???}, skip." >&2;
		return;
	}

	cat $mod_file >&3
	# always append a new line
	echo >&3
}

OUTPUT_FILE=$1
shift

printf "" >$OUTPUT_FILE
chmod +x $OUTPUT_FILE

exec 3>>$OUTPUT_FILE

# Reset output file
cat <<EOF >&3
#!/bin/bash
#
# ustb-cli: A utility script for USTB web.
#
# Copyright  2020-2025    Shuaicheng Zhu <jason23347@gmail.com>
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

EOF

load_module conf
load_module util

for mod in $@; do
	load_module $mod
done

load_module main

exec 3>&-
chmod +x $OUTPUT_FILE
