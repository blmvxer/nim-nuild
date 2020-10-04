import strutils, osproc, os, fab

var
  build = open("build.conf", fmRead)
  ssl: string
  opt: string
  compiler: string
  binName: string
  buildType: string
  buildFile: string
  installDir: string
  termux: bool
  buildString = "nim "

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
          red("[!]Nuild read config error, opt=")
      elif line.contains("termux="):
        if line.replace("termux=", "") == "true":
          termux=true
        elif line.replace("termux=", "") == "false":
          termux=false
        else:
          termux=false
      elif line.contains("install="):
        installDir = line.replace("install=", "")
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
  if buildFile.isEmptyOrWhitespace:
    discard
  else:
    buildString = (buildString & buildFile)   
  
proc main() =
  white("Reading Configuration File\n\n")
  readConf()
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
