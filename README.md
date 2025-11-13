# DLL-Injection

**DLL Injection** is a technique where an attacker forces a target process to load a custom DLL to run code in that process’ context. Red-teamers use it to simulate credential theft, API hooking, or process manipulation while defenders use telemetry to detect abnormal module loads and suspicious API usage.  

**Mitigation / Detection:** monitor unexpected module loads, enable code-signing policies, and alert on suspicious CreateRemoteThread/SetWindowsHookEx usage.  

**Ethics:** Only test DLL injection in lab environments or systems you own/have explicit permission to assess.

## DLL Injection

In this repo i'll provide the methodology behind DLL-Injection and my code sample of an obfuscated stand alone malicious DLL that can lead to code execution when attached or loaded via rundll32

As i've already mentioned DLL-Injection is injecting a DLL path to another process  

The objective of DLL injection is to cause the target process to load the DLL file & execute it  

For this to happen the malware trojan will contain the path to the DLL file

## Mechanism of DLL Injection

Our trojan containing the malcious code (Shellcode) will allocate memmory to the target process using `VirtualAllocEx` Win API 

Then the trojan will write the shellcode to the newly allocated memmory in the target process using `WriteProcessMemmory` Win API  

It will then create `LoadLibrary` thread leveraging the Win API `CreateRemoteThread` & passing some parameters to it including loadlibrary & Path-to-Dll 

For our trojan to determine the address of LoadLibrary function it will use the `GetProcAddress` function from kernel32.dll which loads at the same address for all processes.Therefore GetProcAddress() is used to get the LoadLibrary function from kernel32.dll within the malware trojan itself & then use the same address for the target process

In order to execute the shellcode as soon as the dll is loaded by LoadLibrary function include the Runshellcode user defined function on the `DLL_PROCESS_ATTACH` case for it to be executed when DLL_PROCESS_ATTACH is triggered   

<img src="https://imgur.com/0vyljPe.png" height="70%" width="75%" alt="COM Hijacking Steps"/>

The DLLs exported RunShellcode function is as shown below  

Note that it isn't stable on C2s reverse-shells e.g Meterpreter or Sliver

<img src="https://imgur.com/MO6TBS2.png" height="70%" width="75%" alt="COM Hijacking Steps"/>

## API calls for DLL injection

There are a total of four APIs that are used during DLL Injection, they include the following:  
   &nbsp;&nbsp;&nbsp;&nbsp;   ◇ `GetProcAddress`       →    Used to get LoadLibraries function address from Kernel32.dll  
   &nbsp;&nbsp;&nbsp;&nbsp;   ◇ `VirtualAllocEx`                →    Used to allocate memmory to the targets process  
   &nbsp;&nbsp;&nbsp;&nbsp;   ◇ `WriteProcessMemmory`    →    Used to write the DLL's path to the targets process  
   &nbsp;&nbsp;&nbsp;&nbsp;   ◇ `CreateRemoteThread`      →    Used with two parameters LoadLibrary's address & DLL's Path to execute the copied shellcode in the targets process  

## DLL-Injector Path Auto-Detection

⇒ &nbsp;For the automatic-detection all we need to do is ensure that the DLL is in the same folder as the injector  
⇒ &nbsp;Then in the source-code we need to set pathToDLL variable as a global variable

<img src="https://imgur.com/nk5FDnW.png" height="50%" width="45%" alt="COM Hijacking Steps"/>

⇒ &nbsp;Then we need to ensure that we call `GetPathToDLL()` first in the main function before anything else so that it will construct the path for us
⇒ &nbsp;In the user-defined GetPathToDLL function, we leverage the help of Win API `GetCurrentDirectory` which takes two parameters Buffer-length & Buffer to retrive the current directory for the current process
⇒ &nbsp;Then we use the strcat function to append the actual executable at the end of the path to make it complete 

<img src="https://imgur.com/egamUBu.png" height="70%" width="75%" alt="COM Hijacking Steps"/>

<img src="https://imgur.com/OYgusTN.png" height="70%" width="75%" alt="COM Hijacking Steps"/>

































