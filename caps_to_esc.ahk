SetCapsLockState, off
SetCapsLockState, alwaysoff 

Capslock::
SetCapsLockState, alwaysoff
; SetCapsLockState, alwaysoff
;SetCapsLockState, off
Send {LControl Down}
KeyWait, CapsLock
Send {LControl Up}
if ( A_PriorKey = "CapsLock" )
{
Send {Esc}
}
return
