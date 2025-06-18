groups=$($GAM print groups member $user|grep example.edu)

for i in $(cat suspended-round2.txt); do gam $i show groups > groups.txt;done
