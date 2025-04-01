'25/03/25 - RLB - v5.0
'Standalone script to playback files on Media folder on current storage
'NO FADE as not working on Series 5 players
'remember to use 3840x2160x60p:fullres (also applies to 7680x2160, 4320x3840) to ensure that still images are properly scalled at 4K for landscape/portrait mode 


Sub Main()

	'video mode screen for Series 4 players and older
	series4_and_older_videomode = "1920x1080x60p"
	'series4_and_older_videomode = "3840x2160x30p"
	'series4_and_older_videomode = "3840x2160x30p:fullres"
	'series4_and_older_videomode = "3840x2160x60p:fullres"

	'series 4 and older orientation
	'identity, rot90, rot180, rot270 
	m.series4_and_older_orientation = "identity"

	'video mode screen for Series 5 players
	series5_videomode = "1920x1080x60p"
	'3840x2160x30p max 4K portrait mode for HD1025
	'series5_videomode = "3840x2160x30p:fullres"
	'series5_videomode = "3840x2160x60p:fullres"
	'series5_videomode = "3840x2160x60p"

	'series 5 orientation
	'normal, 90, 180, 270
	series5_orientation = "normal"

	m.msgPort = CreateObject("roMessagePort")
	b = CreateObject("roByteArray")
	b.FromHexString("ffffffff")
	color_spec% = (255*256*256*256) + (b[1]*256*256) + (b[2]*256) + b[3]
	vm = CreateObject("roVideoMode")
	vm.SetBackgroundColor(color_spec%)
	SystemLog = CreateObject("roSystemLog")
	
	m.model = ""
	m.firmware_version = ""
	'm.ipv4address$ = ""

	di = CreateObject("roDeviceInfo")
	m.model = di.GetModel()
	outputNumber = Mid(m.model, 3, 1)
	m.firmware_version = di.GetVersion()

	m.preloadedimage = false
	m.series5 = CheckLastValueIsFive(m.model)
	if m.series5 then
		print "Player is a Series 5."
		print "series5_videomode: "; series5_videomode
		print "series5_orientation: "; series5_orientation
	else
		print "Player is NOT a Series 5."
		print "series4_and_older_videomode: "; series4_and_older_videomode
		print "series4_and_older_orientation: "; m.series4_and_older_orientation
	end if

	m.IsXC5 = CheckModelRange(m.model)
	if m.IsXC5 then
		print "Player is a XC."
	else
		print "Player is NOT a XC."
	end if
	
	if outputNumber = "1" AND NOT m.series5 then
		print ""
		print " @@@ series4_and_older_videomode @@@ "
		print ""
		vm.Setmode(series4_and_older_videomode)
		SystemLog.sendline("@@@ series4_and_older_videomode: " + series4_and_older_videomode)
		' notifyBottom(series4_and_older_videomode)
		
	else if outputNumber = "1" or outputNumber = "2" or outputNumber = "4" AND m.series5 then
		print ""
		print " @@@ series5_videomode @@@ "
		print ""
		SystemLog.sendline("@@@ series5_videomode: " + series5_videomode)
		sm = vm.GetScreenModes()

		sm[0].name = "HDMI-1"
		sm[0].video_mode = series5_videomode
		sm[0].transform = series5_orientation
		sm[0].display_x = 0
		sm[0].display_y = 0
		sm[0].enabled = true
	  
		if (sm[1] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			print ""
			print "@@@ HDMI-2 Should be set here... @@@ "
			print ""
			sm[1].name = "HDMI-2"
			sm[1].video_mode = series5_videomode
			sm[1].transform = series5_orientation
			sm[1].display_x = 0
			sm[1].display_y = 2160
			sm[1].enabled = false
		end if

		if (sm[2] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			sm[2].name = "HDMI-3"
			sm[2].video_mode = series5_videomode
			sm[2].transform = series5_orientation
			sm[2].display_x = 0
			sm[2].display_y = 0
			sm[2].enabled = false
		  end if
	
		  if (sm[3] <> invalid and Instr(0, sm[1].name, "HDMI") <> 0) then
			sm[1].name = "HDMI-4"
			sm[3].video_mode = series5_videomode
			sm[3].transform = series5_orientation
			sm[3].display_x = 0
			sm[3].display_y = 0
			sm[3].enabled = false
		  end if

		vm.SetScreenModes(sm)

		reportedVideoMode = vm.GetScreenModes()[0].video_mode
		print "Series 5 reportedVideoMode: "; reportedVideoMode
		SystemLog.sendline("@@@ Series 5 reportedVideoMode: " + reportedVideoMode)
		' NotifyBottom(reportedVideoMode)
	end if	

	graphicPlaneWidth = vm.GetResX()
	graphicPlaneHeight = vm.GetResY()

	print "graphicPlaneWidth: "; graphicPlaneWidth
	print "graphicPlaneHeight: "; graphicPlaneHeight

	videoPlaneWidth = vm.GetVideoResX()
	videoPlaneHeight = vm.GetVideoResY()

	print "videoPlaneWidth: "; videoPlaneWidth
	print "videoPlaneHeight: "; videoPlaneHeight

	r1CoordinateX = 0
	r1CoordinateY = 0

	r2CoordinateX = 0
	r2CoordinateY = 0

	r1Width = vm.GetResX()
	r1Height = vm.GetResY()

	r2Width = vm.GetResX()
	r2Height = vm.GetResY()

	m.r1 = createobject("rorectangle",r1CoordinateX,r1CoordinateY,r1Width,r1Height)
	m.r2 = createobject("rorectangle",r2CoordinateX,r2CoordinateY,r2Width,r2Height)

	'''''''''''''''''''''''''''''''''''''''
	SystemLog.sendline("@@@ Rectangle 1 param: " + str(r1CoordinateX) + " , " +  str(r1CoordinateY) + " , " + str(r1Width) + " , " +  str(r1Height))
	SystemLog.sendline("@@@ Rectangle 2 param: " + str(r2CoordinateX) + " , " +  str(r2CoordinateY) + " , " + str(r2Width) + " , " +  str(r2Height))
	SystemLog.sendline("@@@ Graphics Plane width: " + str(vm.GetResX()) + " - Graphics Plane height: " + str(vm.GetResY()))
	SystemLog.sendline("@@@ Video Plane width: " + str(vm.GetVideoResX()) + " - Video Plane height: " + str(vm.GetVideoResY()))

	print "@@@ Rectangle 1 param: " + str(r1CoordinateX) + " , " +  str(r1CoordinateY) + " , " + str(r1Width) + " , " +  str(r1Height)
	print "@@@ Rectangle 2 param: " + str(r2CoordinateX) + " , " +  str(r2CoordinateY) + " , " + str(r2Width) + " , " +  str(r2Height)
	print "@@@ Graphics Plane width: " + str(vm.GetResX()) + " - Graphics Plane height: " + str(vm.GetResY())
	print "@@@ Video Plane width: " + str(vm.GetVideoResX()) + " - Video Plane height: " + str(vm.GetVideoResY())

	m.sTime = createObject("roSystemTime")
	gpioPort = CreateObject("roControlPort", "BrightSign")
	gpioPort.SetPort(m.msgPort)	
	m.StartDelayTimer = StartDelayTimer
	m.sh = CreateObject("roStorageHotplug")
	m.sh.SetPort(m.msgPort)
	m.mountedPath = ""
	m.ActivePlaylist = []
	m.ImageTransitionTimeoutVal = 5000
	
	StoragePath = FindSourcePath()
	print "StoragePath: "; StoragePath

	ListMediaFiles(StoragePath)
	StartInfoDelayTimer()
	
	while true
	    
		msg = wait(0, m.msgPort)
		
		'print "type of msgPort is ";type(msg)
	
		if type(msg) = "roControlDown" then
		
			button = msg.GetInt()

			print ""
			print " GPIO roControlDown GPIO "; button 
			print m.sTime.GetLocalDateTime()
			print ""
				
			if button = 12 then 
				print " @@@ GPIO 12 pressed @@@  "
				stop
			end if
		else if type(msg) = "roControlUp" then
			button = msg.GetInt()
		else if type(msg) = "roDatagramEvent" then

		else if type(msg) = "roTimerEvent" then

			timerIdentity = msg.GetSourceIdentity()

			UserData = msg.GetUserData()

			if m.InfoDelayTimer <> invalid then
				if m.InfoDelayTimer.GetIdentity() = timerIdentity then

					ipv4address$ = CheckIPAddress()
					if ipv4address$ = "" then
						ipv4address$ = "No IP Address"
					end if

					' NotifyTop(m.model + " - " + m.firmware_version + " - " + ipv4address$)
				end if
			end if	

			if m.DelayTimer <> invalid then
				if m.DelayTimer.GetIdentity() = timerIdentity then
				
					InitialisePlayers()
					
				end if
			end if 	
		
			if m.Imagetransition <> invalid then
				if m.Imagetransition.GetIdentity() = timerIdentity then
			
					if m.v1 <> invalid then
						PlayPlaylist(m.playlist1, 1, 1, m.v1, m.i1)
					end if 
		
				end if
			end if

			if m.ClearImageDelayTimer <> invalid then
				if m.ClearImageDelayTimer.GetIdentity() = timerIdentity then
			
					if m.i1 <> invalid then
						m.i1.StopDisplay()
					end if 
				end if
			end if

			if m.ClearVideoDelayTimer <> invalid then
				if m.ClearVideoDelayTimer.GetIdentity() = timerIdentity then
			
					if m.v1 <> invalid then
						m.v1.StopClear()
					end if 
				end if
			end if
		else if type(msg) = "roVideoEvent" then	

			VideoPlayerEventReceived = msg.GetInt()

			if VideoPlayerEventReceived = 8 then 
	
				VideoSourceIdentity = msg.GetSourceIdentity()
				VideoSourceIdentity$ = VideoSourceIdentity.toStr()
	
				if m.PlaybackAA <> invalid then
				
					FindMyID = m.PlaybackAA.lookup(VideoSourceIdentity$)
	
					if FindMyID = "v1" then
						'Load the next file here
						PlayPlaylist(m.playlist1, 1, 1, m.v1, m.i1)
					end if 
				end if 	
			end if
		end if				
	end while
End Sub



Function StartDelayTimer()

	retval = false

	m.DelayTimer = invalid
	
	m.DelayTimer = CreateObject("roTimer")
	m.DelayTimer.SetUserData({name:"DelayTimer"})
	m.DelayTimer.SetPort(m.msgPort)
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddMilliseconds(1000)
	m.DelayTimer.SetDateTime(newTimeout)
	ok = m.DelayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function StartInfoDelayTimer()

	retval = false

	m.InfoDelayTimer = invalid
	
	m.InfoDelayTimer = CreateObject("roTimer")
	m.InfoDelayTimer.SetUserData({name:"InfoDelayTimer"})
	m.InfoDelayTimer.SetPort(m.msgPort)
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddMilliseconds(5000)
	m.InfoDelayTimer.SetDateTime(newTimeout)
	ok = m.InfoDelayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function ListMediaFiles(storagePath)

    PlayableFileOnStorage = CreateObject("roArray", 1, true)
	m.mountedPath = storagePath + "Media/"
    FileOnStorage = ListDir(m.mountedPath)
    m.playlist1 = CreateObject("roArray", 1, true)
    index = 0
    ext = ""

	for each file in FileOnStorage

		' Get full extension (up to 5 chars from end to handle ".JPEG")
		ext = ucase(right(file,5))
		
		if right(ext, 4) = ".MP4" or right(ext, 4) = ".MOV" or right(ext, 4) = ".JPG" or ext = ".JPEG" or right(ext, 4) = ".PNG" then 
			if right(ext, 4) = ".MP4" or right(ext, 4) = ".MOV" then 
				filetype = "video"
			else if right(ext, 4) = ".JPG" or ext = ".JPEG" or right(ext, 4) = ".PNG" then
				filetype = "image"
			end if    
	
			if left(file,2) <> "._" then
				PlayableFileOnStorage.push(file)
				filepath$ = m.mountedPath + file
				m.playlist1[index] = {filename: file, filepath: filepath$, filetype: filetype}                   
				index = index + 1
			end if
		end if
	next

	SortFilesABC()

	if m.playlist1.count() > 0 then

		print " @@@ File(s) in Media folder @@@ "
		playlistIndex = 0
		for each file in m.playlist1
			print m.playlist1[playlistIndex].filename
			playlistIndex = playlistIndex + 1
		next     
		print ""

		ok = m.StartDelayTimer()

		if ok = true then
			return true
		end if
	else
		print " @@@ No file in Media folder @@@ " 
	end if 
End Function



Sub NotifyTop(message As String)

	print message
	videoMode = CreateObject("roVideoMode")
	resX = videoMode.GetResX()
	resY = videoMode.GetResY()

	videoMode = invalid
	rectangle = CreateObject("roRectangle", resX/4, resY/6, resX/2, resY/24)
	textParameters = CreateObject("roAssociativeArray")
	textParameters.LineCount = 1
	textParameters.TextMode = 2
	textParameters.Rotation = 0
	textParameters.Alignment = 1
	m.textWidgetTop = CreateObject("roTextWidget", rectangle, 1, 2, textParameters)
	m.textWidgetTop.PushString(message)
	m.textWidgetTop.Show()
End Sub


Sub NotifyMiddle(message As String)

	print message
	videoMode = CreateObject("roVideoMode")
	resX = videoMode.GetResX()
	resY = videoMode.GetResY()

	videoMode = invalid
	rectangle = CreateObject("roRectangle", resX/4, (resY/3)*2, resX/2, resY/24)
	textParameters = CreateObject("roAssociativeArray")
	textParameters.LineCount = 1
	textParameters.TextMode = 2
	textParameters.Rotation = 0
	textParameters.Alignment = 1
	m.textWidgetMiddle = CreateObject("roTextWidget", rectangle, 1, 2, textParameters)
	m.textWidgetMiddle.PushString(message)
	m.textWidgetMiddle.Show()
End Sub


Sub NotifyBottom(message As String)

	print message
	videoMode = CreateObject("roVideoMode")
	resX = videoMode.GetResX()
	resY = videoMode.GetResY()

	videoMode = invalid
	rectangle = CreateObject("roRectangle", resX/4, (resY/2)+ (resy/4), resX/2, resY/24)
	textParameters = CreateObject("roAssociativeArray")
	textParameters.LineCount = 1
	textParameters.TextMode = 2
	textParameters.Rotation = 0
	textParameters.Alignment = 1
	m.textWidgetBottom = CreateObject("roTextWidget", rectangle, 1, 2, textParameters)
	m.textWidgetBottom.PushString(message)
	m.textWidgetBottom.Show()
End Sub



Function StartImagetransitionTimer(TimeOnScreen as integer)As boolean

	retval = false
	
	m.Imagetransition = CreateObject("roTimer")
	m.Imagetransition.SetUserData({name:"Imagetransition"})
	m.Imagetransition.SetPort(m.msgPort)
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddMilliseconds(TimeOnScreen)
	m.Imagetransition.SetDateTime(newTimeout)
	ok = m.Imagetransition.Start()

	if ok then
		return true
	end if 

	return retval	
End Function



Function StartPreloadedPlayTimer(VideoIndex as Integer) As object

	retval = false
    
	m.PreloadPlayTimer = CreateObject("roTimer")
    m.PreloadPlayTimer.SetUserData({name:"PreloadPlayTimer", VideoIndex: VideoIndex})
    m.PreloadPlayTimer.SetPort(m.msgPort)

    newTimeout = m.sTime.GetLocalDateTime()
    newTimeout.AddMilliseconds(300)
    m.PreloadPlayTimer.SetDateTime(newTimeout)
	ok = m.PreloadPlayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function StartClearImageDelayTimer() As boolean

	retval = false
    
	m.ClearImageDelayTimer = CreateObject("roTimer")
    m.ClearImageDelayTimer.SetUserData({name:"ClearImageDelayTimer"})
    m.ClearImageDelayTimer.SetPort(m.msgPort)

    newTimeout = m.sTime.GetLocalDateTime()
    newTimeout.AddMilliseconds(150)
    m.ClearImageDelayTimer.SetDateTime(newTimeout)
	ok = m.ClearImageDelayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function StartClearVideoDelayTimer() As boolean

	retval = false
    
	m.ClearVideoDelayTimer = CreateObject("roTimer")
    m.ClearVideoDelayTimer.SetUserData({name:"ClearVideoDelayTimer"})
    m.ClearVideoDelayTimer.SetPort(m.msgPort)

    newTimeout = m.sTime.GetLocalDateTime()
    newTimeout.AddMilliseconds(150)
    m.ClearVideoDelayTimer.SetDateTime(newTimeout)
	ok = m.ClearVideoDelayTimer.Start()

	if ok then
		return true
	end if 

	return retval
End Function



Function PlayPlaylist(Playlist as Object, playlistNum as integer, fileIndex as integer, videoplayer as object, imageplayer as object) As Boolean

	m.ActivePlaylist[playlistNum] = playlist
	
	if m.ActivePlaylist[playlistNum].count() >= 0 then
		
		if m.PlayfileIndex[fileIndex] = -1 or m.PlayfileIndex[fileIndex] >= m.ActivePlaylist[playlistNum].count() then
			m.PlayfileIndex[fileIndex] = 0
		end if

		if m.PlayfileIndex[fileIndex] <= m.ActivePlaylist[playlistNum].count() then

			VideoIndex = m.PlayfileIndex[fileIndex]
				
			' NotifyMiddle(m.ActivePlaylist[playlistNum][VideoIndex].filename)

			if VideoIndex + 1 >= m.ActivePlaylist[playlistNum].count() then
				NextVideoIndex = 0
			else
				NextVideoIndex = VideoIndex + 1
			end if
		
			if m.ActivePlaylist[playlistNum][VideoIndex].filetype = "video" or m.ActivePlaylist[playlistNum][VideoIndex].filetype = "image" then

				if m.ActivePlaylist[playlistNum][VideoIndex].filetype = "video" then
					ok = videoplayer.PlayFile({Filename: m.ActivePlaylist[playlistNum][VideoIndex].filepath})
					StartClearImageDelayTimer()
				else if m.ActivePlaylist[playlistNum][VideoIndex].filetype = "image" then
					'stop
					if m.series5 and not m.IsXC5 then
						'better handling of 4K images on Series HD1025 with current firmware with/without :fullres
						ok = videoplayer.PlayStaticImage({Filename: m.ActivePlaylist[playlistNum][VideoIndex].filepath})
					else
						'Better image handling than PlayStaticImage() on XT1144 for 4K images in landscape and portait mode
						ok = imageplayer.DisplayFile(m.ActivePlaylist[playlistNum][VideoIndex].filepath)
						StartClearVideoDelayTimer()
					end if	
					StartImagetransitionTimer(m.ImageTransitionTimeoutVal)
				end if
			end if
		end if

		if m.PlayfileIndex[fileIndex] = m.ActivePlaylist[playlistNum].count() then
			m.PlayfileIndex[fileIndex] = 0
		else if m.ActivePlaylist[playlistNum].count() >  VideoIndex then
			VideoIndex = VideoIndex + 1
			m.PlayfileIndex[fileIndex] = VideoIndex
		end if
	end if
End Function



Function InitialisePlayers()


	m.PlaybackAA = {}
	
	m.v1 = CreateObject("roVideoPlayer")
	m.v1.SetPort(m.msgport)
	m.v1.SetRectangle(m.r1)
	'm.v1.SetViewMode(0)
	'm.v1.SetViewMode(m.viewmode_scale)
	m.v1.SetLoopMode(1)
	if not m.series5 then
		m.v1.SetTransform(m.series4_and_older_orientation)
	end if
	
	m.v1_IDTemp = m.v1.GetIdentity()
	m.v1_ID = m.v1_IDTemp.Tostr()
	m.PlaybackAA.AddReplace(m.v1_ID, "v1")


	m.i1 = CreateObject("roImageWidget", m.r2)
	m.i1.SetDefaultMode(0)
	if not m.series5 then
		m.i1.SetTransform(m.series4_and_older_orientation)
	end if	
	'm.i1.SetRectangle(m.r2)

	m.Playfile1Index = 0

	m.PlayfileIndex = CreateObject("roArray", 1, true)
	m.PlayfileIndex[1] = m.Playfile1Index

	m.Playlists = CreateObject("roArray", 1, true)
	m.Playlists[1] = m.playlist1
	
	m.VideoPlayers = CreateObject("roArray", 1, true)
	m.VideoPlayers[1] = m.v1

	'starting playback here
	PlayPlaylist(m.playlist1, 1, 1, m.v1, m.i1)
End Function



Function FindDestPath()
    destinationPaths = ["SSD:", "SD:", "USB1:"]
    for each destination in destinationPaths
        if IsMounted(destination) then
            return destination+"/"
        end if
    next
    return "unknown"
End Function



Function FindSourcePath()
    sourcePaths = ["USB1:", "SD:", "SSD:"]
    for each source in sourcePaths
		print "source: "; source
        if IsMounted(source) and IsExists(source+"/autorun.brs") then
            return source+"/"
        end if
    next
    return "unknown"
End Function



Function IsMounted(path as String)
    if CreateObject("roStorageHotplug").GetStorageStatus(path).mounted then
        return true
    end if

    return false
End Function



Function IsExists(path as String)
    file = CreateObject("roReadFile", path)
    if type(file) = "roReadFile" then
        return true
    end if

    return false
End Function



function CheckLastValueIsFive(inputString as String) as Boolean
    if inputString = invalid or Len(inputString) = 0 then
        return false ' Handle empty or invalid strings
    end if

    lastChar = Right(inputString, 1) 
    if lastChar = "5" then
        return true
    else
        return false
    end if
end function



function CheckModelRange(inputString as String) as Boolean
    if inputString = invalid or Len(inputString) = 0 then
        return false ' Handle empty or invalid strings
    end if

    model_range = Left(inputString, 2) 
    if model_range = "XC" then
        return true
    else
        return false
    end if
end function



Function SortFilesABC() As Boolean

	if m.playlist1.count() > 0 then
        for i% = m.playlist1.count() - 1 to 1 step -1
            for j% = 0 to i% - 1
                if m.playlist1[j%].filename > m.playlist1[j%+1].filename then
                    tmp = m.playlist1[j%].filename
                    m.playlist1[j%].filename = m.playlist1[j%+1].filename
                    m.playlist1[j%+1].filename = tmp
                    
                    ttmp$ = m.playlist1[j%].filetype
                    m.playlist1[j%].filetype = m.playlist1[j%+1].filetype
                    m.playlist1[j%+1].filetype = ttmp$

					ptmp$ = m.playlist1[j%].filepath
                    m.playlist1[j%].filepath = m.playlist1[j%+1].filepath
                    m.playlist1[j%+1].filepath = ptmp$
                end if
            next
        next
    end if
End Function



Function CheckIPAddress()As String
	retval = ""
	nc = CreateObject("roNetworkConfiguration", 0)
	if type(nc) = "roNetworkConfiguration" then
		currentConfig = nc.GetCurrentConfig()
		if type(currentConfig) = "roAssociativeArray" then
			print ""
			print "Current Network Parameters"
			print currentConfig
			ipv4address$ = currentConfig.ip4_address
			print currentConfig.ip4_address
			retval = currentConfig.ip4_address
			print ""
		end if
	end if	
	return retval
End Function