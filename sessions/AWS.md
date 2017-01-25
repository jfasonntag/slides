# Amazon Web Services Cloud Computing

* In this session we will work with the [Amazon Web Services (AWS)](https://aws.amazon.com) Elastic Cloud (EC2) virtual servers.
* The aim will be for you to be able to launch a **general purpose cluster** on AWS.
	* By this I mean a cluster for any kind of suitable parallel computing task: R, python, julia, C++, fortran.
	* You could even dream of setting up a cluster for matlab or stata. however, you will need to buy a license for each compute node you want to launch. 
		* Here is the place where using proprietary software stops being fun.
* Julia has a very nice way to launch a cluster on AWS **directly from your computer**, with the help of the great [ASW.jl](https://github.com/JuliaParallel/AWS.jl) package.
* However, for many other applications, and to manage large julia jobs as well, it is good to know how to work with AWS.


## Prerequisites For This Session

**Before** you come to class:

1. get an account on AWS
	1. go to [https://aws.amazon.com/console/](https://aws.amazon.com/console/)
	1. sign-in or create a new amazon web services account
1. Windows users: get PuTTY 
	1. user guide for connecting to [aws for windows users](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)
	1. I won't be able to spend a lot of time helping windows user to get set up. I recommend you have a look at this document before coming. 
	1. You won't connect to AWS via PuTTY in the end if all goes according to plan.
1. you need **python**
	1. mac os el capitan/yosemite: built-in python is not working. 
		* need more complete version from homebrew
		* get homebrew if you don't have it
		* do `brew install python`
		* (optional) install amazon command line interface (AWS CLI) via `pip install awscli`
	1. windows: get [anaconda python](https://www.continuum.io/downloads)
		* (optional) install AWS CLI via installer at [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)
1. you need **starcluster**
	* now that you have python, do `easy_install starcluster` on your command line
	* we will edit this file together in class.



## CAUTION: Financial Costs!

* AWS is a pay as you go system.
* There is a free-tier arrangement under which you can use the service without having to pay for it.
* However, this is subject to some restrictions. Once you exceed the limits, you will be charged.
* It is **very important** that you go to your amazon AWS console and have a close eye on your Billing Status (top right, click on your name)
* Inside Billing Status there is an *estimated cost of your free tier usage*. you can see how much of your free time and resources you have used up already in the current month.
* **Danger**: You are charged for volumnes (i.e. hard disks) that are kept available for you. reduce the number of active volumes and snapshots in your aws console to a minimum. 
	* *terminating* an instance instead of just *stopping* it automatically detaches a volume and therefore prevents this problem.


---------------------


# In Class


## What is [AWS EC2](https://aws.amazon.com/ec2/)?

* A cloud computing service.
* It's an on-demand system: you pay what you use.
* The price varies according to demand at any given time.
* There is a **free usage tier**, which we will be using: your first year is for free (on certain machine types).
* machine = **instance**
* You can pre-pay and thus reserve some instances, but that's more expensive
* You can say you only want to launch the instance at a certain unit price (it varies, remember)


### What could it cost?

* There is a very [easy-to-use calculator](http://s3.amazonaws.com/calculator/index.html).
* Here is [an example configuration](http://s3.amazonaws.com/calculator/index.html#r=IAD&s=EC2&key=calc-BAFF4EDF-DB58-473D-9C94-4B0D02F3B72F)
* There are research grants.

## Setup in Class

The aim here is to show you how to set up a general purpose compute cluster on AWS Elastic Compute 2 (AWS EC2). We will use starcluster to help us interact with our clusters. First, we need to enter your security credentials into the config of starcluster, that you created already.

### amazon credentials?

* You connect to AWS via ssh.
* ssh is based on a key-pair system: there is a unique key that fits into a unique *lock* (it's not called lock in reality). We have to create such a key-pair for you.

#### Setting up an AWS user: Identity Access Management (IAM)

* go to the [AWS console](https://aws.amazon.com/console/)
* click on your name, security credentials
* in the popup, click on **get started with IAM Users**
* **create new users**
* choose a user name for yourself
* keep tick box ticked.
* **create**
* you **now for the last and only time** able to download the security credentials for this user: Do it, and save to a secure place on your computer.

#### creating an SSH keypair for your user

* go to the [AWS Console](https://console.aws.amazon.com/ec2/)
* top right, select the region through which you want to connect to AWS. I choose US East in Virginia.
	* the region you choose has impacts on which kind of *machine images* (more below) that are available to you.
* click on **key pairs**
* create new key pair
* give it a name (i called mine *us-east-virginia*), and download
* save in a location that you will remember. Standard for *nix users is `~/.ssh/us-east-virginia.pem`

#### add user to a group

* create a new group
* give it administrator rights

### Amazon Machine Images (AMI)

* Go to console and click on launch an instance
* Base instances have just a minimal set of software installed
* we don't have to pay each time we connect for the time it takes to install all of our software
* ideally, we do that once, and that create a *new* AMI from the machine we installed our software on
* I created such an AMI for you. It has R, julia, python and some basic development tools (gnu compiler collection and cmake)
* There is an AMI marketplace where you can find (for free or for a charge) other people's AMIs. 

### Volumes

* You probably will want to store data on the cluster, either as input or output
* similarly: you may want to install add-on software (R, python and julia packages for example)
* Whatever you store on the disk of your AMI instance will be lost when you end the session
	* that is, the AMI stays exactly the same to the moment you created it
	* everything else that you add to it during a session will be lost

* One solution are **Volumes**
* Think that you get your own hard disk drive from AWS, and everytime you start a cluster, you would bring the disk, and they will plug into the cluster
* this way you could add data each time you use the cluster, and use it again the next time.

#### Attach Volume to the provided AMI

* The AMI I created for you has 2 links for a volume to be attached
* one for R libraries and one for julia packages
* The volume needs to be mounted as `/data`. more below.


## Starcluster

* Starcluster helps us with all of those tasks

### Steps

* create star cluster sample config: type `star cluster help`


### Put Credentials into star cluster config

* open `~/.starcluster/config` in a text editor
* from your downloaded credentials file, add access information
* set region to

```Makefile
AWS_REGION_NAME = us-east-1
AWS_REGION_HOST = ec2.us-east-1.amazonaws.com
```

* define keypair to use
* select AMI ami-e2c8de88
	* Amazon Machine Image (AMI): a certain type of *computer*, i.e. OS, pre-installed software, etc. 
	* The machines are pretty much empty, so you would have to install all of your software each time before actually starting to work
	* AMIs prevent you from having to do that.

## Run `starcluster`

* do `start starcluster myfirst` where `myfirst` is the name of the cluster you want to create
* this will uses your default cluster template from the config
* after it's done, you can connect to the master node with `starcluster sshmaster myfirst`
* to stop, do `starcluster stop myfirst`

        
            