# Our custom nutch configuration

Our configuration for nutch for crawling uni-leipzig.de.

Please adapt the regex-urlfilter with the [check-nutch-regex-urlfilter project](https://github.com/mam10eks/check-nutch-regex-urlfilter).

You will usually do the following:
* install nutch locally
* inject this configuration into the nutch installation
* customize your conf/regex-urlfilter by using [the check-nutch-regex-urlfilter project](https://github.com/mam10eks/check-nutch-regex-urlfilter).

## Install Nutch

Please install java with JAVA_HOME and maven.

An Example installation could look like:
```
#do the next steps as root
sudo -s

#Download nutch 1.13
wget http://mirrors.ae-online.de/apache/nutch/1.13/apache-nutch-1.13-bin.tar.gz

#create installation directory and extract nutch into it
mkdir -p /opt/nutch
cp apache-nutch-1.13-bin.tar.gz /opt/nutch
cd /opt/nutch
tar -xf apache-nutch-1.13-bin.tar.gz

#replace original conf by our custom configuration
cd apache-nutch-1.13
rm -Rf conf
git clone https://github.com/mam10eks/nutch_config.git
mv nutch_config conf
```

Now you should have a directory `/opt/nutch/apache-nutch-1.13/bin`.
Please add the following line to `etc/profile`:
```
export PATH="/opt/nutch/apache-nutch-1.13/bin:${PATH}"
```

After a restart (or executing `. /etc/profile`) you should be able to execute `nutch` and `crawl`.
You will see some hits after executing it.

Now you could start crawling (after you have set up your regex-urlfilter.txt with [the check-nutch-regex-urlfilter project](https://github.com/mam10eks/check-nutch-regex-urlfilter)).
Simply create a directory `seed` with an file `seed/seed.txt` with seed urls.
After that you could execute `crawl seed crawl 100` which will use the second parameter (`crawl`) as the directory for the crawldb and will execute 100 rounds (argument 3)
