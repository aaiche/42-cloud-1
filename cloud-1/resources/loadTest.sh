#!/bin/bash -ex
yum -y update
yum install -y httpd24-tools
ab -n 500000 -c 15 -t 600 -s 120 -r http://myVpcLoadBalancer-1118744953.eu-central-1.elb.amazonaws.com/
