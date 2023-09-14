#!/bin/bash
VERSION="1.1.1"
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
NC='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'

log_err() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${RED}ERROR${NC}] %b\n" "$@"
}

log_info() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][INFO] %b\n" "$@"
}

log_warning() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${YELLOW}WARNING${NC}] \033[0m%b\n" "$@"
}

log_note() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${BLUE}NOTE${NC}] \033[0m%b\n" "$@"
}

log_success() {
  printf "[$(date +'%Y-%m-%dT%H:%M:%S.%2N%z')][${GREEN}SUCCESS${NC}] \033[0m%b\n" "$@"
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
      2) log_err "导出失败，至少需要一个参数\n";Help;;
      3) log_err "缺少参数\n";Help;;
      4) log_err "对象类型列表文件未找到。默认: resources.list\n";Help;;
      5) log_err "K8s apiserver 不可用。或者权限不足\n";;
      6) log_err "Namespace未找到\n";;
      7) log_err "请提供namespace名称。 e.g. --namespace kube-system 或者 -n kube-system\n";;
      8) log_err "缺少命令行工具kubectl\n";;
      9) log_err "未知参数 $UNKNOWN_ARG";;
      130) log_err "Ctrl + C!";;
      *) log_err "导出失败\n"
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
  bash ${0} -n NAMESPACE TYPE1 TYPE2 ...

  将此命名空间中的所有deployment导出到目录：${WORKDIR}
  bash ${0} -n NAMESPACE deployment

  使用 -f 一次导出多个对象类型。 默认的文件名是：resources.list
  bash ${0} -n NAMESPACE -f

  自定义对象类型列表文件
  bash ${0} -n NAMESPACE -f yourConfigurationFile

  从所有命名空间循环导出 TYPE。 警告：导出集群级对象类型时不要使用此选项
  bash ${0} -A TYPE1 TYPE2 ...
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
      if [ "$TYPE" == "deployment" ] || [ "$TYPE" == "statefulset" ];then
        for SUB in $(kubectl -n "$NS" get "$TYPE" | awk '{print $1}' | sed 1d);do
          if [ ! -d "$WORKDIR"/"$NS"/"$TYPE"/"$SUB" ];then
            mkdir -p "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"
          fi
          kubectl -n "$NS" get "$TYPE" "$SUB" -o yaml | sed -r '/^    deployment\.kubernetes\.io\/revision:/d' | sed -r '/^ *creationTimestamp:/d' | sed -r '/^        kubectl\.kubernetes\.io\/restartedAt:/d' | sed -r '/^  generation:/d' | sed -r '/^status/,$d' | sed -r '/^  resourceVersion:/d' | sed -r '/^  selfLink:/d' | sed -r '/^  uid:/d' | sed -r '/^    kubectl\.kubernetes\.io\/last-applied-configuration:/{N; d}' > "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"/"$SUB"-"$TYPE"-"$DATE".yaml
          log_info "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"/"$SUB"-"$TYPE"-"$DATE".yaml
        done
      elif kubectl -n "$NS" get "$TYPE" &> /dev/null;then
        if [ ! -d "$WORKDIR"/"$NS"/"$TYPE" ];then
          mkdir -p "$WORKDIR"/"$NS"/"$TYPE"
        fi
        for SUB in $(kubectl -n "$NS" get "$TYPE" | awk '{print $1}' | sed 1d);do
          kubectl -n "$NS" get "$TYPE" "$SUB" -o yaml | sed -r '/^ *creationTimestamp:/d' | sed -r '/^  resourceVersion:/d' | sed -r '/^  selfLink:/d' | sed -r '/^  uid:/d' | sed -r '/^status/,$d' | sed -r '/^  generation:/d' | sed -r '/^    kubectl\.kubernetes\.io\/last-applied-configuration:/{N; d}' | sed -r '/^  clusterIP:/d' | sed -r '/  clusterIPs:/{N; d}' > "$WORKDIR"/"$NS"/"$TYPE"/"$SUB"-"$TYPE"-"$DATE".yaml
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
        printf 'K8s yaml export script, version: %s\n' "$VERSION"
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

    if [ $ARCHIVED == true ];then
      tar -zcf "$WORKDIR".tar.gz "$WORKDIR" --remove-files
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

    if [ $ARCHIVED == true ];then
      tar -zcf "$WORKDIR".tar.gz "$WORKDIR" --remove-files
    fi
    exit 0

  fi
}

main "$@"