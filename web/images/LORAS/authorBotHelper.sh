bigNum=43
for file in *.png
do
  bigNum=$((bigNum + 1))
  echo $bigNum;
  mv "$file" "${bigNum}.png"
done