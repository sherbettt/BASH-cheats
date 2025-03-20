### § подсветка вывода файла

1) sudo apt-get install python3-pygments
2) sudo pygmentize -g <filename> (pcat)
3) добавить в .bashrc
	<br/>alias pcat='pygmentize -g'

<br/>pygmentize file.py
<br/>pygmentize -l javascript input_file
<br/>pygmentize -L lexers
<br/>pygmentize -f html -o output_file.html input_file.py
<br/>pygmentize -L formatters
<br/>pygmentize -f html -O "full,linenos=True" -o output_file.html input_file

Подсветка bat (batcat)

1) wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
	<br/>или
	<br/>sudo apt install bat
2) sudo dpkg -i bat_0.24.0_amd64.deb
3) bat --version
4) batcat <file>
