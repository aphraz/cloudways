#!/usr/bin/gawk -f
	
BEGIN {
FS="\""
PROCINFO["sorted_in"]="@val_num_desc" 
printf("\n|%-20s   |%-8s\n\n" ,"  Bots", " Hits")
} 

match($6,/(((\w+)?[^\/(ro)][Bb]ot((-\w+)+)?)|((\w+)?[^\/][Cc]rawler))/) \
{BOT[substr($6,RSTART,RLENGTH)] +=1} 

END {
x=1
for (b in BOT) {printf("| %-22s| %-8d\n", b, BOT[b]) 
if (x==10)break
x++}
}
