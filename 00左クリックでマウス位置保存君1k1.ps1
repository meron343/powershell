[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
	#左クリック時の戻り値を計算
	$L_CLK = [System.Windows.Forms.MouseButtons]::Left.value__
	$R_CLK = [System.Windows.Forms.MouseButtons]::Right.value__
	$MouseValuetemp= [System.Windows.Forms.Control]::MouseButtons.value__
#$text= [System.Windows.Forms.Control]::ModifierKeys.Tostring("")
while($true){
	#クリック時の戻り値を計算
	$MouseValue= [System.Windows.Forms.Control]::MouseButtons.value__

	if($MouseValue  -eq $MouseValuetemp){

	}else{
		switch ($MouseValue) {
		    $L_CLK {
			$MouseEV= "L_CLK"
		    }
		    $R_CLK {
			$MouseEV= "R_CLK"
		    }

		    Default {
		        $MouseEV= $MouseValue.ToString()
		    }
		}

		$X = [System.Windows.Forms.Cursor]::Position.X
		$Y = [System.Windows.Forms.Cursor]::Position.Y
		if($MouseValue -eq 0){
			if( ($X -ne $tempX)-or ($Y -ne $tempY)){
				Write-Host -NoNewline "DoRackDrop"
				Write-Host マウス位置表示："X: $X | Y: $Y EventNO= $MouseEV Drop`a" $MouseValue.ToString()
				$tempX =$X
				$tempY =$Y
			}
		}else{
			#文字を置くちゃう
	 		#[System.Windows.Forms.SendKeys]::SendWait("{`a}") #sendkey
			#マウス動かしちゃう
			#[System.Windows.Forms.Cursor]::Position= New-Object System.Drawing.Point(1, 1)
			

			Write-Host マウス位置表示："X: $X | Y: $Y EventNO= $MouseEV `a" $MouseValue.ToString()
			$tempX =$X
			$tempY =$Y
		}



	}

	Start-Sleep -Milliseconds 100

	$MouseValuetemp=$MouseValue



#Read-Host
}


[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
while($true){
	Start-Sleep -s　1

	$X = [System.Windows.Forms.Cursor]::Position.X
	$Y = [System.Windows.Forms.Cursor]::Position.Y

	$ZZ= [System.Windows.Forms.Control]::MouseButtons.value__


          

	Write-Output マウス位置表示："X: $X | Y: $Y z $Z z $ZZ"

#Read-Host
}
