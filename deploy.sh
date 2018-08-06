#!/bin/bash

#Usage : sh deploy <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>

sh deploy-frankfurt.sh $1 $2
sh deploy-london.sh $1 $2
sh deploy-paris.sh $1 $2
