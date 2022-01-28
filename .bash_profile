parse_git_branch() {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='\[\033[36m\]\W\[\033[37m\]$(parse_git_branch)\[\033[00m\]$ '

export GOPATH=$HOME/go
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/k8s/istio-1.0.5/bin
export GO111MODULE=on

# PD-DEV CONTEXT FILES
export KUBECONFIG=$HOME/.kube/config.k8s-pddev.ameiling
#export KUBECONFIG=$HOME/.kube/local

export TILLER_NAMESPACE="ameiling"

alias d='docker'
alias h='helm'
alias dr='draft'
alias m='make'
alias k='kubectl'
alias sed='gsed'
alias neverland='/usr/local/bin/goland'

klog () {
	kubectl logs -n $TILLER_NAMESPACE $(kubectl get pod -n $TILLER_NAMESPACE -l app=$1 -o jsonpath='{.items[0].metadata.name}') -c $1
}

# clean namespace
kclean () {
    kubectl delete deployments --all -n -n $TILLER_NAMESPACE
    kubectl delete services --all -n $TILLER_NAMESPACE
    kubectl delete configMaps --all -n $TILLER_NAMESPACE
}
# kubectl get pods
kgp () {
    kubectl get pods -n $TILLER_NAMESPACE
}
# kubectl get pods --watch
kgpw () {
	kubectl get pods -n $TILLER_NAMESPACE -w
}
# kubectl get services
kgs () {
    kubectl get services -n $TILLER_NAMESPACE
}
# kubectl get virtualServices
kgvs () {
    kubectl get virtualServices -n $TILLER_NAMESPACE
}
# kubectl get configMaps
kgcm () {
    kubectl get configMaps -n $TILLER_NAMESPACE
}

kdash () {
       	kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/alternative/kubernetes-dashboard.yaml; kubectl proxy
}

kiali () {
	kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001
}

mgoport () {
    kubectl port-forward -n $TILLER_NAMESPACE $(kubectl get pod -n $TILLER_NAMESPACE -l app=mongo -o jsonpath='{.items[0].metadata.name}') 27017:27017
}

kup () {
    export POD_NAME=$(kubectl get pods --namespace logging -l "app=kibana,release=kibana" -o jsonpath="{.items[0].metadata.name}")
    echo "Visit http://127.0.0.1:5601 to use Kibana"
    kubectl port-forward --namespace logging $POD_NAME 5601:5601
}

mock () {
    mockery -name $1 -inpkg -case snake .
}

# nuke docker containers
ndc () {
    # delete all docker containers including all volumes
    docker rm -vf $(docker ps -a -q)
}

# nuke docker images
ndi () { 
    # delete all docker images
    docker rmi -f $(docker images -a -q)
}

# nuke docker all
nda () {
    # delete all docker containers including all volumes
    docker rm -vf $(docker ps -a -q)
    # delete all docker images
    docker rmi -f $(docker images -a -q)
    # show images
    echo IMAGES:
    docker images
    echo " "
    # show containers
    echo RUNNING CONTAINERS:
    docker ps
    echo " "
    # shoe non-running containers
    echo STOPPED CONTAINERS:
    docker ps -a
    echo " "
}

tart () {
	rm -rf ~/.helm
	kubectl delete pods --namespace $TILLER_NAMESPACE -l name=tiller
	echo Waiting for tiller to be ready.....
	sleep 30
	helm init --service-account tiller --tiller-namespace $TILLER_NAMESPACE
}

orion () {
    local orion_repos=(
        configurations
        environments
        missions
        networkmap
        publish
	saltparser
        # web-client
    )
    local base_path="$HOME/Documents/Products/Orion"
    for repo in "${orion_repos[@]}"; do
        local repo_path="$base_path/$repo"
        echo "$repo_path"
        if ! (
            pushd "$repo_path" > /dev/null &&
            "$@" &&
            popd > /dev/null
        ); then
            return
        fi
    done
}
