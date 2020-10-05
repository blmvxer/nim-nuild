import strutils, osproc, os, fab

var
  build = open("build.conf", fmRead)
  depConf = open("deps.conf", fmRead)
  ssl: string
  opt: string
  compiler: string
  threads: string
  binName: string
  buildType: string
  buildFile: string
  installDir: string
  termux: bool
  deps: bool
  buildString = "nim "
  objCheck: bool
  fieldCheck: bool
  rangeCheck: bool
  boundCheck: bool
  overflowCheck: bool
  floatCheck: bool
  nanCheck: bool
  infCheck: bool
  nilCheck: bool
  refCheck: bool


proc readConf() =
  while true:
    try:
      var line: string
      line = readLine(build)
      if line.contains("#"):
        discard
      elif line.contains("build="):
        binName = line.replace("build=", "")
        buildFile = line.replace("build=", "c ")
      elif line.contains("cc="):
        compiler = line.replace("cc=", "")
      elif line.contains("release="):
        buildType = line.replace("release=", "")
      elif line.contains("ssl="):
        ssl = line.replace("ssl=", "")
      elif line.contains("opt="):
        opt = line.replace("opt=", "")
        if opt == "speed":
          discard
        elif opt == "size":
          discard
        else:
          opt = ""
      elif line.contains("threads="):
        if line.replace("threads=" , "") == "on":
          threads = "--threads:on"
        else:
          threads = ""
      elif line.contains("termux="):
        if line.replace("termux=", "") == "true":
          termux=true
        else:
          termux=false
      elif line.contains("install="):
        installDir = line.replace("install=", "")
      elif line.contains("deps="):
        if line.replace("deps=", "") == "false":
          deps=false
        elif line.replace("deps=", "") == "true":
          deps=true
        else:
          deps=false
      else:
        discard line
    except EOFError:
      break

proc nuildFile() =
  if ssl.isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & "-d:ssl ")
  if buildType.isEmptyOrWhitespace:
    discard
  else:
    if buildType == "true":
      buildString = (buildString & "-d:release ")
    elif buildType == "false":
      buildString = (buildString & "-d:debug ")
    else:
      discard
  if compiler.isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & "--cc:" & compiler & " ")
  if opt.isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & "--opt:" & opt & " ")
  if threads. isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & threads & " ")
  if buildFile.isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & buildFile)   
  
proc depCheck() =
  if deps == false:
    white("\nNo dependencies found\n")
  else:
    white("\nInstalling dependencies, this may take a bit\n")
    let (pkgs, errn) = execCmdEx("nimble list -i")
    while true:
      try:
        var line: string
        line = readLine(depConf)
        if line.contains("#"):
          discard
        else:
          if pkgs.contains(line):
            green("[+] " & line & " already installed...skipping")
            continue
          else:
            yellow("[!]Installing " & line)
            let (output, errn) = execCmdEx("nimble install -y " & line)
            if errn != 0:
              red(output)
            else:
              green("[+]Installed " & line)
      except EOFError:
        break

proc main() =
  white("Reading Configuration File\n")
  readConf()
  depCheck()
  nuildFile()
  white("build string: " & buildString & "\n")
  sleep(2000)
  green("[+]Building file...")
  let (output, errn) = execCmdEx(buildString)
  if errn != 0:
    red(output)
  else:
    if installDir.isEmptyOrWhitespace:
      yellow("\n[!]Install directory not set, binary in current directory")
    else:
      try:
        binName = binName.replace(".nim", "")
        yellow("\n[!]Installing " & binName & " to " & installDir)
        if termux == false:
          installDir = (installDir & "/" & binName)
          let install = execProcess("sudo mv " & binName & " " & installDir)
          discard install
          green("[+]Installed")
          quit(0)
        elif termux == true and binName == "nuild":
          installDir = ("$PREFIX/bin/" & binName)          
        elif termux == true and binName != "nuild":
          installDir = (installDir & "/" & binName)
        else:
         discard
        let install = execProcess("mv " & binName & " " & installDir)
        discard install
        green("[+]Installed")
        quit(0)
      except:
        red("[!]Error during installation")
main()
