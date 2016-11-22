service iptables stop
chkconfig iptables off

#   Update Hosts Easily
while read line; do
    echo $line >> /etc/hosts
done <hosts

service sshd restart

export $INSTALL_FOLDER=/home/gv8
export $INSTALL_DIR=$INSTALL_FOLDER/install

rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR

#   Extract and update owner
tar -zxvf hadoop-2.7.3.tar.gz -C $INSTALL_DIR
rm -f /usr/local/hadoop
ln -s $INSTALL_DIR/hadoop-2.7.3 /usr/local/hadoop
chown -R root:hadoop /usr/local/hadoop
chown -R root:hadoop $INSTALL_DIR/hadoop-2.7.3

#   Update Permissions to Hadoop Folders Explicitly
find $INSTALL_DIR/hadoop-2.7.3/etc/hadoop -type f -exec chmod 664 {} \;
find $INSTALL_DIR/hadoop-2.7.3 -type d -exec chmod 775 {} \;
find $INSTALL_DIR/ -type d -exec chmod 775 {} \;

#   Extract and update owner
tar -zxvf jdk-8u111-linux-x64.tar.gz -C /home/gv8/install
chown -R root:hadoop $INSTALL_DIR/jdk1.8.0_111
rm -f /usr/bin/java
rm -f /usr/bin/javac
rm -f /usr/lib/jvm/jdk1.8.0_111
rm -f /usr/local/jvm
mkdir -p /usr/lib/jvm/
ln -s $INSTALL_DIR/jdk1.8.0_111/bin/java /usr/bin/java
ln -s $INSTALL_DIR/jdk1.8.0_111/bin/javac /usr/bin/javac
ln -s $INSTALL_DIR/jdk1.8.0_111/ /usr/lib/jvm/jdk1.8.0_111
ln -s /usr/lib/jvm /usr/local/jvm
chown -R root:hadoop /usr/lib/jvm/jdk1.8.0_111
chown -R root:hadoop /usr/local/jvm

#   Allow anyone in group hadoop to access HDFS
mkdir -p /usr/share/hdfs
chown -R root:hadoop /usr/share/hdfs
chmod 775 /usr/share/hdfs

#   Convenient variables
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_111
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop

#   Update machine bash profile

if [ ! -f /etc/profile-backup-hadoopinstall ];
then
    cp /etc/profile /etc/profile-backup-hadoopinstall
else
    cat /etc/profile-backup-hadoopinstall > /etc/profile
fi

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

#   Set master
echo "weenie-master" > $HADOOP_CONF_DIR/masters

#   If master add ourself to slaves
rm -f $HADOOP_CONF_DIR/slaves

if [ $1="master" ]
  then
    echo "weenie-master" >> $HADOOP_CONF_DIR/slaves
fi

#   Get our slaves and add to slaves
tail -n +2 hosts > slavehosts

N=16;
cat slavehosts | grep -o ".\{$N\}$" > slavehostnames 

while read line; do
    echo $line >> $HADOOP_CONF_DIR/slaves
done < slavehostnames


#   Copy all .xml files into config

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
cp ./hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh

echo "Installation complete, please type: 'source /etc/profile' to update path variables"
echo "If you need to run this again, please remove changes to:"
echo "    /etc/hosts"

