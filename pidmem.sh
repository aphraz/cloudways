#!/bin/bash
for A in $(ls -l /home/master/applications/| grep "^d" | gawk '{print $NF}');
    do
        echo -e "\n";
        echo -e $A && gawk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx;
        awk -v OFS="\t" 'BEGIN{printf("\n%s\t%s\n", "PID","Memory")} {SUM[$11] += $13} END {for (s in SUM) \
	printf("%d\t%.2f %s\n", s,SUM[s]/1024/1024,"MB") | "sort -nbrk2,2 | head"}' /home/master/applications/$A/logs/php-app.access.log
