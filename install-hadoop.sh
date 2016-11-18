service iptables stop
chkconfig iptables off

#   Update Hosts Easily
while read line; do
    echo $line >> /etc/hosts
done <hosts

service sshd restart

#   Extract and update owner
tar -zxvf hadoop-2.7.3.tar.gz
rm -f /usr/local/hadoop
ln -s /home/gv8/install/hadoop-2.7.3 /usr/local/hadoop
chown -R root:hadoop /usr/local/hadoop
chown -R root:hadoop ./hadoop-2.7.3

#   Update Permissions Explicitly
#find /hadoop-2.7.3/bin -type f -exec chmod 755 {} \;
#find /hadoop-2.7.3/sbin -type f -exec chmod 755 {} \;
#find /hadoop-2.7.3/etc/hadoop -type f -exec chmod 644 {} \;
#find /hadoop-2.7.3/share -type f -exec chmod 644 {} \;
#find /hadoop-2.7.3/share -type d -exec chmod 755 {} \;
#find /hadoop-2.7.3/include -type f -exec chmod 644 {} \;
#find /hadoop-2.7.3/lib/native/*.a -type f -exec chmod 644 {} \;
#find /hadoop-2.7.3/lib/native/*.so.* -type f -exec chmod 755 {} \;

#   Extract and update owner
tar -zxvf jdk-8u111-linux-x64.tar.gz
chown -R root:hadoop ./jdk1.8.0_111
rm -f /usr/bin/java
rm -f /usr/bin/javac
rm -f /usr/lib/jvm/jdk1.8.0_111
mkdir -p /usr/lib/jvm/
ln -s /home/gv8/install/jdk1.8.0_111/bin/java /usr/bin/java
ln -s /home/gv8/install/jdk1.8.0_111/bin/javac /usr/bin/javac
ln -s /home/gv8/install/jdk1.8.0_111/ /usr/lib/jvm/jdk1.8.0_111
chown -R root:hadoop /usr/lib/jvm/jdk1.8.0_111

#   Update Permissions
#find ./jdk1.8.0_111/bin -type f -exec chmod 755 {} \;
#find ./jdk1.8.0_111/bin -type f -exec chmod 755 {} \;

mkdir -p /usr/share/hdfs
chown -R root:hadoop /usr/share/hdfs
chmod 775 /usr/share/hdfs

#   Update machine bash profile
cp /etc/profile /etc/profile-backup

export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_111

#   Sets Hadoop Variables
echo "export HADOOP_HOME=/usr/local/hadoop" >> /etc/profile
echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> /etc/profile
echo "export HADOOP_MAPRED_HOME=$HADOOP_HOME" >> /etc/profile
echo "export HADOOP_COMMON_HOME=$HADOOP_HOME" >> /etc/profile
echo "export HADOOP_HDFS_HOME=$HADOOP_HOME" >> /etc/profile
echo "export YARN_HOME=$HADOOP_HOME" >> /etc/profile

#   Sets Java Variables
echo "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_111" >> /etc/profile
echo "export PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin" >> /etc/profile

export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop

echo "weenie-master" > $HADOOP_CONF_DIR/masters

if [ $1="master" ]
  then
    echo "weenie-master" >> $HADOOP_CONF_DIR/slaves
fi

tail -n +2 hosts > slavehosts

N=16;
cat slavehosts | grep -o ".\{$N\}$" > slavehostnames 

while read line; do
    echo $line >> $HADOOP_CONF_DIR/slaves
done < slavehostnames

cp ./core-site.xml $HADOOP_CONF_DIR/

if [ $1="master" ]
  then
    cp ./master-hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
fi

if [ $1="slave" ]
  then
    cp ./slave-hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
fi

cp ./mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
cp ./yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml
