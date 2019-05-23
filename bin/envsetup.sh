export KUBECONFIG=${OUT}/minikube.conf
        if minikube status; then
          minikube start
        fi
    fi

    export TEST_ENV=$env
}

function stop() {
    if [ "$env" == "minikube" ]; then
        minikube stop
    fi
}
