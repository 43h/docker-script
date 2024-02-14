#! /bin/sh

#check system
is_ubuntu=`lsb_release -i | grep -i ubuntu | wc -l`

if [ $is_ubuntu -ne 1 ];then
echo "\nThe script only runs on ubuntu systems!!!\n"
exit 0
fi

#uninstall old docker
sudo apt remove docker docker-engine docker.io containerd runc

#make tmp dir
rm -rf docker.tmp
mkdir docker.tmp

#download package index
wget https://download.docker.com/linux/ubuntu/dists/$(lsb_release -cs)/pool/stable/amd64/ -O docker.tmp/docker.txt


if [ -f docker.tmp/docker.txt ];then
echo "start to parse...\n"
else
echo "fail to fetch docker-package-index"
exit 0
fi

#get package list
cat docker.tmp/docker.txt | awk '{
	if(index( $0, "<a" ))
	{
		if(!index( $0, "../" ))
        {
          gsub(/<.*>/,"",$2);
		  gsub(/.*>/,"",$2);
	      print $2;
	   }
	}
}' > docker.tmp/pkg.txt

#get package name(without version)
cat docker.tmp/pkg.txt | awk '{
    gsub(/_.*/,"",$1);
	print $1;
}' | sort -u -o docker.tmp/name.txt

#get package name(with version)
cat docker.tmp/name.txt | while read line
do
cat docker.tmp/pkg.txt | grep -i $line | sort -Vr | tail -n 1 >> docker.tmp/last.txt
done

#download package
cat docker.tmp/last.txt | while read line
do
wget -P docker.tmp https://download.docker.com/linux/ubuntu/dists/$(lsb_release -cs)/pool/stable/amd64/$line
done

#install
sudo dpkg -i docker.tmp/*.deb

#del cache
rm -rf docker.tmp
