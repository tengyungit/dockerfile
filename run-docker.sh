#!/bin/bash

#help
docker_help () {
    printf  "\nAuto update code and run build."
    printf  "\n"
    printf  "\nUsage"
    printf  "\n\t$0 [OPTIONS] command"
    printf  "\n"
    printf  "\nOptioins"
    printf  "\n\t-n     - project name [must]"
    printf  "\n\t-b     - git branch name (default dev)"
    printf  "\n\t-p     - port, container 80 ports reflect main port [must]"
    printf  "\n\t-h     - display this help"
    printf  "\n"
    printf  "\nThe commands are:"
    printf  "\n"
    printf  "\n\t$0 -n jilaidai-api -b dev -p 8011"
    printf  "\n"
    printf  "\n"
    exit
}

#check param
if [ $# -lt 1 ]; then
    docker_help
fi

#default param
PROJ_NAME=nil
PORT=8011
BRANCH=dev

#get param
while getopts "n:b:p:h" name;do
    case $name in
        n)
            PROJ_NAME=$OPTARG
            ;;
        b)
            BRANCH=$OPTARG
            ;;
        p)
            PORT=$OPTARG
            ;;
        ?)
            docker_help
            ;;
    esac
done

if [ "$PROJ_NAME" == "nil" ]; then
    docker_help
fi

#check git directory
PROJ_DIR=/home/git
if [ "$PROJ_NAME" == "wiki" ]; then
    PROJ_DIR=/home/git/wiki
fi

if [ ! -e $PROJ_DIR/$PROJ_NAME ]; then
    echo "project code directory not exist:/home/git/$PROJ_NAME"
    exit
fi

#git update
cd $PROJ_DIR/$PROJ_NAME && git pull origin $BRANCH 
#cd /home/git/$PROJ_NAME && git stash && git pull origin dev && git stash pop

#run images
runNum=`docker ps|grep $PROJ_NAME|wc -l`

if [ $runNum -lt 1 ]; then
    runHistory=`docker ps -a|grep $PROJ_NAME|wc -l`
    
    if [ $runHistory -lt 1 ]; then
        docker run --name $PROJ_NAME \
            --restart=always \
            -p $PORT:80 \
            -v /home/git/$PROJ_NAME:/data/www \
            -d 127.0.0.1:5000/web-php7.1:server-conf
    else
        docker restart $PROJ_NAME
    fi
fi
