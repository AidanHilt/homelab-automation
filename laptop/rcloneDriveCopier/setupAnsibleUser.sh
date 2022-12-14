sudo useradd ansible 
echo"======================================================="
echo"Make sure you have an ansible user password ready to go"
echo "Press any key to continue"
while [ true ] ; do
read -t 3 -n 1
if [ $? = 0 ] ; then
exit ;
fi
done
sudo passwd ansible

