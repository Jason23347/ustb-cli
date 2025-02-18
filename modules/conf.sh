VERSION=v2.1

# 0/1, 置0则不会进入CLI模式。
ENABLE_CLI_MODE=1

LOGIN_HOST=202.204.48.82 # 或者 202.204.48.66, login.ustb.edu.cn.

# 存有用户名密码的env文件
ENV_FILE=$HOME/.ustb.env

# 该值可以为空，或者一个合法的IPV6地址。
# 通过 http://cippv6.ustb.edu.cn/get_ip.php 获取的地址通常随MAC绑定。
# 所以，不必每次都重新获取IPV6地址，反正不会变。
DEFAULT_IPV6_ADDRESS=""

# 0/1, 置0则不尝试获取IPV6地址，对确定没有IPV6地址的设备很有用。
ATTEMPT_IPV6=1

# 0/1, 置1则弹出确定窗口是否以当前登录用户重新登录，适用于刷新登录信息的情况。
ALWAYS_USE_DEFAULT_USER=1

# CLOCK settings, do not change.
CLOCK_COLOR="\033[46m"
CLOCK_FORCE_UPDATE=1
# Default: Mon Oct 12  PM
CLOCK_DATE_FORMAT="%a %b %d  %p"
# Width of a digit dot
CLOCK_WIDTH=2
# Spaces between the digits
CLOCK_SPACE=3
# Width for info block in clock mode
CLOCK_INFO_WIDTH=28
