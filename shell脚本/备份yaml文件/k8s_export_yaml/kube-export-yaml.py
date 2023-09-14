import os
import sys
import yaml
import time

scripts = """#!/bin/bash
VERSION="1.1.0-inpy"
# 批量导出k8s对象的yaml

#   -n    指定namespace
#   -f    指定对象类型列表文件
#   -h    输出帮助
#   -A    从所有namespace中导出指定对象类型

# Usage:
#   ./export_yaml.sh [flags] [options]


: "${DEBUG:=false}"
: "${NAMESPACE:="default"}"
: "${CONFIG_ENABLE:=false}"
: "${CONFIGFILE:="resources.list"}"
: "${ALL_NAMESPACE:=false}"
: "${ARCHIVED:=false}"

DATE=$(date +%F-%H%M)
: "${WORKDIR:="yaml-$DATE"}"

ALL_ARG=(
  '-n'
  '--namespace'
  '-f'
  '--file'
  '-h'
  '--help'
  '-A'
  '-v'
  '--version'
  '-a'
)

HAS_KUBECTL="$(type "kubectl" &> /dev/null && echo true || echo false)"
HAS_CLUSTER="$(kubectl cluster-info &> /dev/null && echo true || echo false)"

# set output color
NC='\\033[0m'
RED='\\033[31m'
GREEN='\\033[32m'
YELLOW='\\033[33m'
BLUE='\\033[34m'

log_err() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${RED}ERROR${NC}] %b\\n" "$@"
}

log_info() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][INFO] %b\\n" "$@"
}

log_warning() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${YELLOW}WARNING${NC}] \\033[0m%b\\n" "$@"
}

log_note() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${BLUE}NOTE${NC}] \\033[0m%b\\n" "$@"
}

log_success() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${GREEN}SUCCESS${NC}] \\033[0m%b\\n" "$@"
}

VerifySupported() {
  if [ "${HAS_KUBECTL}" != true ]; then
    exit 8
  fi
  if [ "${HAS_CLUSTER}" != true ]; then
    exit 5
  fi
}

# FailTrap is executed if an error occurs.
FailTrap() {
  result=$?
  if [ "$result" != "0" ]; then
    case $result in
      2) log_err "导出失败，至少需要一个参数\\n";Help;;
      3) log_err "缺少参数\\n";Help;;
      4) log_err "对象类型列表文件未找到。默认: resources.list\\n";Help;;
      5) log_err "K8s apiserver 不可用。或者权限不足\\n";;
      6) log_err "Namespace未找到\\n";;
      7) log_err "请提供namespace名称。 e.g. --namespace kube-system 或者 -n kube-system\\n";;
      8) log_err "缺少命令行工具kubectl\\n";;
      9) log_err "未知参数 $UNKNOWN_ARG";;
      130) log_err "Ctrl + C!";;
      *) log_err "导出失败\\n"
    esac
  fi
  exit $result
}

# help provides possible cli arguments
Help () {
  echo -e "args:
  -n --namespace    指定namespace
  -f --file         指定对象类型列表文件
  -h --help         输出帮助
  -A                从所有namespace中导出指定对象类型
  -v --version      输出版本信息
  -a                将导出的yaml文件压缩为tar

e.g.
  python3 kube-export-yaml.py -n NAMESPACE TYPE1 TYPE2 ...

  将此命名空间中的所有deployment导出到目录：${WORKDIR}
  python3 kube-export-yaml.py -n NAMESPACE deployment

  使用 -f 一次导出多个对象类型。 默认的文件名是：resources.list
  python3 kube-export-yaml.py -n NAMESPACE -f

  自定义对象类型列表文件
  python3 kube-export-yaml.py -n NAMESPACE -f yourConfigurationFile

  从所有命名空间循环导出 TYPE。 警告：导出集群级对象类型时不要使用此选项
  python3 kube-export-yaml.py -A TYPE1 TYPE2 ...
"
}

MainProcess() {
  NS=$1
  TYPE=$2

  case $TYPE in
    deploy) TYPE="deployment";;
    sts) TYPE="statefulset";;
    cm) TYPE="configmap";;
    ing) TYPE="ingress";;
    svc) TYPE="service";;
    sc) TYPE="storageclass";;
    cj) TYPE="cronjob";;
    ds) TYPE="daemonset";;
    sa) TYPE="serviceaccount";;
    po) TYPE="pod";;
    no) TYPE="node";;
    ns) TYPE="namespace";;
  esac

  if ! kubectl -n "$NS" get "$TYPE" &> /dev/null;then
    log_warning "The server doesn't have a resource type ${TYPE}"
  else
    log_info "$NS/$TYPE export start."
    STATE=$(kubectl -n "$NS" get $TYPE 2>&1| sed -n 1p | awk '{print $1}')
    if [ "$STATE" != 'No' ];then
      if kubectl -n "$NS" get "$TYPE" &> /dev/null;then
        if [ ! -d "$WORKDIR"/"$NS"/"$TYPE" ];then
          mkdir -p "$WORKDIR"/"$NS"/"$TYPE"
        fi
        for SUB in $(kubectl -n "$NS" get "$TYPE" | awk '{print $1}' | sed 1d);do
          kubectl -n "$NS" get "$TYPE" "$SUB" -o yaml > "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"-"$TYPE"-"$DATE".yaml
          log_info "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"-"$TYPE"-"$DATE".yaml
        done
      fi
      log_success "$NS/$TYPE export done."
    else
      log_warning "No $TYPE resources found in $NS namespace."
    fi
  fi
}

# Execution
main() {
  #Stop execution on any error
  trap "FailTrap" EXIT
  set -e
  #clear

  # Set debug if desired
  if [ "${DEBUG}" == true ]; then
    set -x
  fi

  if [ ! "$1" ];then
    exit 2
  fi

  VerifySupported
  NUM=0
  while [ $# -gt 0 ]; do
    case $1 in
      '--namespace'|-n)
        shift
        if [ $# -eq 0 ] || [ "${ALL_ARG[*]/$1/}" != "${ALL_ARG[*]}" ];then
          exit 7
        else
          export NAMESPACE=$1
          shift
        fi
        if [ "${ALL_ARG[*]/-A/}" == "${ALL_ARG[*]}" ] && [ $ALL_NAMESPACE != true ] ;then
          if ! kubectl get ns "$NAMESPACE" &> /dev/null; then
            exit 6
          fi
        fi
      ;;
      '--file'|-f)
        shift
        if [ "$1" ] && [ "${ALL_ARG[*]/$1/}" == "${ALL_ARG[*]}" ];then
          export CONFIGFILE=$1
          shift
        fi
        if [ ! -f "$CONFIGFILE" ];then
          exit 4
        fi
        export CONFIG_ENABLE=true
      ;;
      '--help'|-h)
        Help
        exit 0
      ;;
      '-A')
        shift
        export ALL_NAMESPACE=true
      ;;
      -v|'--version')
        printf 'K8s yaml export script, version: %s\\n' "$VERSION"
        exit 0
      ;;
      -a)
        shift
        export ARCHIVED=true
      ;;    
      -*)
        export UNKNOWN_ARG=$1
        exit 9
      ;;
      *)
        TYPES[NUM]=$1
        NUM=$((NUM + 1))
        shift
      ;;
    esac
  done

  if [ "$CONFIG_ENABLE" != true ] && [ "${#TYPES[*]}" -eq 0 ];then
    exit 3
  fi

  if [ ! -d "$WORKDIR" ] ;then
    mkdir "$WORKDIR"
  fi

  if [ "$CONFIG_ENABLE" == true ];then
    if [ $ALL_NAMESPACE == true ];then
      for NS in $(kubectl get ns | sed 1d | awk '{print $1}')
      do
        (awk -F[\#] '{print $1}' "$CONFIGFILE" | sed -r /^$/d) | while read -r TYPE;do
          MainProcess "$NS" "$TYPE"
        done
      done
    elif [ $ALL_NAMESPACE == false ];then
      (awk -F[\#] '{print $1}' "$CONFIGFILE" | sed -r /^$/d) | while read -r TYPE;do
        MainProcess "$NAMESPACE" "$TYPE"
      done
    fi

    if [ "${#TYPES[*]}" -gt 0 ];then
      log_warning "当使用-f选项指定读取列表文件时，命令行中传递的资源类型将被忽略。"
    fi
    exit 0

  fi


  if [ "${#TYPES[*]}" -gt 0 ];then
    if [ $ALL_NAMESPACE == true ];then
      for NS in $(kubectl get ns | sed 1d | awk '{print $1}')
      do
        for((i=0;i<"${#TYPES[*]}";i++));do
          MainProcess "$NS" "${TYPES[i]}"
        done
      done
    elif [ $ALL_NAMESPACE == false ];then
      for((i=0;i<"${#TYPES[*]}";i++));do
        MainProcess "$NAMESPACE" "${TYPES[i]}"
      done
    fi

    exit 0

  fi
}

main "$@"
"""


# 处理yaml文件
def delete_data(file, *args):
    with open(file, 'r+') as f:
        dict_temp = yaml.load(f, Loader=yaml.FullLoader)
        try:
            del dict_temp["metadata"]["annotations"]["kubectl.kubernetes.io/last-applied-configuration"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["managedFields"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["creationTimestamp"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["generation"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["annotations"]["deployment.kubernetes.io/revision"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["resourceVersion"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["selfLink"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["uid"]
        except KeyError:
            pass
        try:
            del dict_temp["spec"]["template"]["metadata"]["creationTimestamp"]
        except KeyError:
            pass
        try:
            del dict_temp["status"]
        except KeyError:
            pass
        # svc
        try:
            del dict_temp["spec"]["clusterIP"]
        except KeyError:
            pass
        try:
            del dict_temp["spec"]["clusterIPs"]
        except KeyError:
            pass
        # pv
        try:
            del dict_temp["metadata"]["annotations"]["pv.kubernetes.io/provisioned-by"]
        except KeyError:
            pass
        try:
            del dict_temp["spec"]["claimRef"]
        except KeyError:
            pass
        # pv & pvc
        try:
            del dict_temp["metadata"]["finalizers"]
        except KeyError:
            pass
        # pvc
        try:
            del dict_temp["metadata"]["annotations"]["pv.kubernetes.io/bind-completed"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["annotations"]["pv.kubernetes.io/bound-by-controller"]
        except KeyError:
            pass
        try:
            del dict_temp["metadata"]["annotations"]["volume.beta.kubernetes.io/storage-provisioner"]
        except KeyError:
            pass
        try:
            del dict_temp["spec"]["template"]["metadata"]["annotations"]["kubectl.kubernetes.io/restartedAt"]
        except KeyError:
            pass

        with open(file, 'w') as f2:
            yaml.dump(dict_temp, f2)


# 生成脚本
with open(".export_yaml.sh", 'w', encoding='utf-8') as file:
    file.write(scripts)

work_dir = "yaml-" + time.strftime('%Y-%m-%d-%H%M', time.localtime(time.time()))
try:
    # 导出
    os.system("chmod +x .export_yaml.sh")
    args = "".join([_ + " " for _ in sys.argv[1:]])
    os.system(f"export WORKDIR={work_dir}")
    ec = os.system(f"./.export_yaml.sh {args}")
    if ec != 0:
        raise Exception
    else:

        for root, dirs, files in os.walk(work_dir, topdown=False):
            for name in files:
                delete_data(os.path.join(root, name))

        if "-a" in sys.argv[1:]:
            os.system(f"tar -zcf {work_dir}.tar.gz {work_dir} --remove-files")

except Exception:
    exit(1)
finally:
    os.remove("./.export_yaml.sh")
