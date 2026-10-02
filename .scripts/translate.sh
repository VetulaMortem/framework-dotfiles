read input
echo $input | tr -d "\"" | sed 's/\\t/\t/g'
