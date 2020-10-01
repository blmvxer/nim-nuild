import strutils, osproc, os

var
  build = open("build.conf", fmRead)
  ssl: string
  opt: string
  compiler: string
  binName: string
  buildType: string
  buildFile: string
  installDir: string
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
  echo("Reading Configuration File\n\n")
  readConf()
  nuildFile()
  echo("build string: " & buildString & "\n")
  sleep(2000)
  echo("Building file...")
  let buildResult = execProcess(buildString)
  echo(buildResult)
  if installDir.isEmptyOrWhitespace:
    discard
  else:
    installDir = (installDir & "/" & binName)
    let installResult = execProcess("sudo cp " & binName & " " & installDir)
    echo(installResult)
main()
