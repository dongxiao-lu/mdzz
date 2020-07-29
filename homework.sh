#!/bin/bash

auth_flag=silfp_algo_auth:754
start_flag=fp_identifyImage_identify:223
end_flag=fp_identifyImage_identify:258
output=result.txt

if [[ -z $1 || ! -f $1 ]]; then
	echo "运行程序需要输入文件名,并且文件存在"
	exit
fi

if [[ -f "$output" ]]; then
	rm "$output" -rf
fi
touch "$output"


result=$(grep 'silfp_algo_auth:' $1 | wc -l)
echo "识别总次数为：$result" > $output
result=$(grep $auth_flag $1 | wc -l)
echo "识别成功次数为：$result" >> $output
# --------------------------------------------------for test 0
# grep 'silfp_algo_auth:' $1|grep -n $auth_flag|cut -d ":" -f 1 > a.txt
# for line in `cat a.txt`
# do
# 	echo line
# done
# rm a.txt
# --------------------------------------------------for test 1
# fu=`grep 'silfp_algo_auth:' $1|grep -n $auth_flag|cut -d ":" -f 1`
# n=1
# te=`echo $fu|awk '{print $'${n}'}'`
# until [[ -z $te ]]
# do
# 	echo $te
# 	((n+=1))
# 	te=`echo $fu|awk '{print $'${n}'}'`
# done
# --------------------------------------------------for test
sum=0
i=0
echo '识别成时间分别为：' >> $output
grep 'silfp_algo_auth:' $1|grep -n $auth_flag|cut -d ":" -f 1 > 'temp.txt'
while read line
do
	# grep 'fp_identifyImage_identify:223' $1|grep -n 'fp_identifyImage_identify:223'|awk '{print $1}'|sed -n "${line}p"
	r1=`grep "${start_flag}" $1|awk '{print $3}'|sed -n "${line}p"`
	echo -e "\t ${r1} \t start" >> $output
	r2=`grep "${end_flag}" $1|awk '{print $3}'|sed -n "${line}p"`
	echo -e "\t ${r2} \t end\n" >> $output

	# a=${r1%.*}
	# b=${r2%.*}
	a=`date -d "${r1%.*}" +%s` #标准时间转换成时间戳
	b=`date -d "${r2%.*}" +%s`
	if [[ $a -eq $b ]]; then
		a=${r1#*.}
		b=${r2#*.}
		if [[ $a -ge $b ]]; then	#开始时间比结束时间要大，获取出错
			echo "The start time is bigger than the end time"
			echo -e "error time is: \t\t $r1 \t start \t\t $r2 \t end"
		else
			# echo $a $b
			dif=`expr $b - $a`	#不能用$(($b-$a))，遇到0xx - 0xx时，会认为不是十进制
			dif_all="$dif_all$dif "
			sum=$(($sum+$dif))
			i=$(($i+1))
			# echo -e "dif=$dif \t sum=$sum \t i=$i"
		fi
	else
		if [[ $a -gt $b ]]; then	#开始时间比结束时间要大，获取出错
			echo "The start time is bigger than the end time"
			echo -e "error time is: \t\t $r1 \t start \t\t $r2 \t end"
		else
			dif=$((($b - $a) * 1000))
			a=${r1#*.}
			b=${r2#*.}
			
			dif=`expr $dif + $b - $a`	#不能用$(($b-$a))，遇到0xx - 0xx时，会认为不是十进制
			dif_all="$dif_all$dif "
			sum=$(($sum+$dif))
			i=$(($i+1))
		fi
	fi
done < 'temp.txt'

rm 'temp.txt'

echo -e "识别成功$i次耗时：\n\t $dif_all" >> $output
if [ $sum -lt 0 -o $i -lt 0  ]
then
	ave=$((sum / i))
	echo "识别成功平均耗时：$ave" >> $output
fi
	
cat $output
rm $output
