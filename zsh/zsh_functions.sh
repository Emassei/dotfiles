random_music_track(){
	arg1=$1
	cd ~/music/$arg1
	song=$(ls | shuf -n 1)
        mpv --term-playing-msg='Title: ${media-title}' $song
	trap 'cd ~' 0
}

random_track_from_directory(){
	arg1=$1
	cd ~/music/$arg1
	artist=$(ls | shuf -n 1)
	cd $artist
	song=$(ls | shuf -n 1)
        mpv --term-playing-msg='Title: ${media-title}' $song
	trap 'cd ~' 0
}
connect_to_vpn(){
        arg1=$1
	nmcli connection up $arg1
}

function stopwatch(){
  date1=`date +%s`;
   while true; do
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
    sleep 0.1
   done
}

function exchange_to_col(){
	arg1=$1
	cash $arg1 usd col
}

function exchange_to_usd(){
        arg1=$1
	cash $arg1 col usd
}

function spanish_translate(){
        arg1=$1
	dict -d spa-eng $arg1
}

# Loop a command and show the output in vim
loop() {
	echo ":cq to quit\n" > /tmp/log/output
	fc -ln -1 > /tmp/log/program
	while true; do
		cat /tmp/log/program >> /tmp/log/output ;
		$(cat /tmp/log/program) |& tee -a /tmp/log/output ;
		echo '\n' >> /tmp/log/output
		vim + /tmp/log/output || break;
		rm -rf /tmp/log/output
	done;
}

# port scan
port_scan() {
	echo "Enter IP address range you want to scan (ex.192.168.1.0/24)"
	read ip_range
	if [[ $ip_range == 192* ]]
	then
		command='-sTV'
	else
		command='-PnV'
	fi

  nmap $command  -p 20,21,22,23,25,53,80,110,119,123,143,161,194 $ip_range | grep "open\|report"
	echo "Which IP do you want to scan for vulnerabilities?"
	read vulnerable_ip
	nmap --script vulners $command $vulnerable_ip
}

# Custom cd
c() {
	cd $1;
	#ls;
}
alias cd="c"

