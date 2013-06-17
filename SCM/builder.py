#
# BuildTools - builder.py
#
# For this to work:
#	- The account running this script has to be set up to access Github through ssh.
#   - Homebrew needs to have been installed, and with homebrew, xctool needs to have been installed.
#
# Created by Steven Woolgar on 06/04/2013.
# Copyright (c) 2013 Wal-Mart Stores, Inc, Inc. All rights reserved.
#

# Globals

ProductToBuild = 'Undefined'
BranchToBuild = 'master'
VerboseMode = False
NoCloneMode = False
PrintProductMode = False
NoSubmoduleUpdate = False
ProductElements = []
BuildFolderPath = 'BuildFolder'
KeychainPassword = 'password'
BuildNumber = 0
ConfigToBuild = 'Debug'
DistributeWithTestflight = False
SchemeToBuild = 'NONE'
XCTool = '/usr/local/bin/xctool'


def copyBuildToServer(product):
    if VerboseMode:
        print('Copying '+product.attrib['id']+'the built product to server.')


def pathToCodesignAllocateTool():
    xcodePath = pathToCurrentXcode()
    return xcodePath+'/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate'


def pathToCurrentXcode():
    import subprocess
    path = subprocess.check_output("xcode-select -print-path", shell=True)
    return path.replace(' ', '\ ')


def bumpTheRevisionNumber():
    print('Bumping the revision #')


def storeGitHashAndBranchToInfoPlist():
    print('storing Git hash and branch name to Info.plist')


# Get the number of revisions in the repo to use as a build #
def determineBuildNumberFromRevisions():
    global BuildFolderPath
    global BuildNumber

    # p.communicate will wait until completion and return the output into revListCount

    import subprocess
    revListCount = subprocess.check_output("git rev-list HEAD | wc -l", shell=True)
    BuildNumber = revListCount.strip()
    if VerboseMode:
        print('Build number is '+BuildNumber)


# Get all of the externals for the product by doing the submodule dance.
# Requires that the cwd() be the the repo's folder root.
def gitUpdateSubmodules(product):
    global BuildFolderPath

    if VerboseMode:
        print('Started updating submodules: '+product.attrib['id'])

    import subprocess

    cmd = ['git', 'submodule', 'init']
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()

    cmd = ['git', 'submodule', 'sync']
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()

    cmd = ['git', 'submodule', 'update', '--init', '--recursive']
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()

    if VerboseMode:
        print('Finished updating submodules: '+product.attrib['id'])


# Unlock the keychain
def unlockKeychain():
    global KeychainPassword

    import subprocess

    cmd = ['security', 'unlock-keychain', '-p', KeychainPassword, '/Users/jenkins/Library/Keychains/login.keychain']
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()


# Checkout the branch that we want to build on.
def gitCheckoutBranch(branchName):
    global BuildFolderPath
    if VerboseMode:
        print('Checking out branch: '+branchName)

    import subprocess

    cmd = ['git', 'checkout', branchName]
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()


# Clone the source code of the product
def gitClone(product):
    global BuildFolderPath
    # Determine the git repo from the 'product' XML data

    gitElement = product.find('git')
    repoElement = gitElement.find('repo')
    repoPath = repoElement.text

    if VerboseMode:
        print('Started git cloning: '+product.attrib['id'])

    import os
    if not os.path.exists(BuildFolderPath):
        os.mkdir(BuildFolderPath)

    import subprocess
    cmd = ['git', 'clone', repoPath, BuildFolderPath]
    p = subprocess.Popen(cmd, cwd='.')
    p.wait()

    if VerboseMode:
        print('Finished git cloning: '+product.attrib['id'])


# Create hash of keys and print all project ID's
def checkProduct(product):
    print('checkProduct', product)


# Look through the XML file and list all of <product id="">
def printProducts():
    global ProductElements

    print('Configured products:', ProductElements)
    for productElement in ProductElements:
        print(productElement.attrib['id'])


# Set the globals flags and parameters to build with given a command line.
def parseCommandLineArguments():
    global ProductToBuild
    global BranchToBuild
    global VerboseMode
    global NoCloneMode
    global PrintProductMode
    global NoSubmoduleUpdate
    global KeychainPassword
    global ConfigToBuild
    global SchemeToBuild
    global DistributeWithTestflight

    import argparse

    parser = argparse.ArgumentParser(prog='builder', description='Build Xcode Projects.')
    parser.add_argument('product', action='store', default='Undefined', nargs='*',
                        help="""One of the products in the XML file <product id="foo">""")
    parser.add_argument('-v', action='store_true', default=False, help='Verbose mode')
    parser.add_argument('-n', action='store_true', default=False, help="Don't clone, use current source")
    parser.add_argument('-l', action='store_true', default=False, help='List the products defined in the config file')
    parser.add_argument('-p', action='store', dest='keychainPassword',
                        help='Supply the password to unlock the keychain')
    parser.add_argument('-m', action='store_true', default=False,
                        help="Don't update submodules, use sub current source")
    parser.add_argument('-b', action='store', dest='branch', default='dev', help='Which branch to build')
    parser.add_argument('-c', action='store', dest='configuration', default='Debug',
                        help='Which configuration to build')
    parser.add_argument('-s', action='store', dest='scheme', default='NONE', help='Which scheme to build')

    args = parser.parse_args(['-v', '-n', '-p buildstuff', '-b dev', '-c Debug', '-s walmart',
                             'Walmart-iOS'])  # Hardcoded for testing
#    args = parser.parse_args()                                                   # This is what will be used once done

    # TODO: Instead of using the first supplied product, store the list, then iterate over them building them all.

    ProductToBuild = args.product[0].strip()    # Strip leading/trailing spaces
    VerboseMode = args.v
    NoCloneMode = args.n
    PrintProductMode = args.l
    NoSubmoduleUpdate = args.m
    BranchToBuild = args.branch.strip()         # Strip leading/trailing spaces
    KeychainPassword = args.keychainPassword.strip()
    ConfigToBuild = args.configuration.strip()
    SchemeToBuild = args.scheme.strip()

    success = True

    if ProductToBuild == 'Undefined':
        success = False

    if VerboseMode and success:
        print('Verbose mode turned on.')

    if PrintProductMode:
        printProducts()

    if ConfigToBuild.lower().contains().startswith('testflight'):
        DistributeWithTestflight = True

    return success


# Open the supplied XML configuration file. This contains all of the products that this script will build.
# Using ElementTree
def processConfigurationFile(configurationsFile):
    global ProductElements
    global ProductToBuild
    global ProductsRoot

    import xml.etree.ElementTree
    productsTree = xml.etree.ElementTree.parse(configurationsFile)
    ProductsRoot = productsTree.getroot()
    ProductElements = ProductsRoot.getchildren()

    return True


# Now codesign the built application.
def codesignProduct(product):
    # Look at the XML file and get the bits we need.

    projectName = product.find('project_file').text
    if VerboseMode:
        print('Codesigning '+projectName)

    # Setup to run the codesign app

    import os
    os.environ['CODESIGN_ALLOCATE'] = pathToCodesignAllocateTool()

    # Find the name of the binary output built by Xcode.

    binaryFile = ''
    for scheme in product.find('schemes'):
        if scheme.find('sname').text == SchemeToBuild:
            binaryFile = scheme.find('binary').text
            break

    if binaryFile != '':
        print('Sign '+binaryFile+'.app')
    else:
        print('Could not sign app because the binary file was not properly defined in the XML config file')


# Call XCTool to build the supplied product which is defined in the XML file.
def buildProduct(product):
    global ProductToBuild
    global SchemeToBuild
    global ConfigToBuild

    entitlement = product.find('entitlement').text
    if VerboseMode and entitlement != '':
        print('entitlement = '+entitlement)

    # Look at the XML file and get the bits we need.

    projectName = product.find('project_file').text

    #TODO: Check the supplied config name to make sure it is valid.
    #TODO: Check the supplied scheme name to make sure it is valid.

    import subprocess

    # Find out the bits we need from the XML file to build.

    buildCmd = XCTool+' -project '+projectName+' -scheme '+SchemeToBuild+' -configuration '+ConfigToBuild

    # Now ask XCTool to clean the actual app for us

    xctoolOutput = subprocess.check_output(buildCmd+' clean', shell=True)
    print('XCTool output: '+xctoolOutput)

    # Now ask XCTool to build the actual app for us

    xctoolOutput = subprocess.check_output(buildCmd+' build', shell=True)
    print('XCTool output: '+xctoolOutput)


# clone, checkout and update submodules, then build the supplied product which is defined in the XML file.
def checkOutAndBuildProduct(product):
    global BranchToBuild
    global BuildFolderPath

    import os
    currentWorkingDirectory = os.getcwd()

    # Create Temporary Directory, CLEANUP will automatically remove it when the script exits.

    if VerboseMode:
        print('=================== Started building: '+product.attrib['id']+' ===================')

    if not NoCloneMode:
        gitClone(product)
    os.chdir('./'+BuildFolderPath)  # The rest needs to happen inside the build folder.

    gitCheckoutBranch(BranchToBuild)

    if not NoSubmoduleUpdate:
        gitUpdateSubmodules(product)

    determineBuildNumberFromRevisions()
    bumpTheRevisionNumber()
    storeGitHashAndBranchToInfoPlist()
    buildProduct(product)
    codesignProduct(product)
    copyBuildToServer(product)

    # Close up show, we are done here

    if VerboseMode:
        print('================= Finished building: '+product.attrib['id']+' ====================')

    if currentWorkingDirectory != '':
        os.chdir(currentWorkingDirectory)

    return True


if processConfigurationFile('buildconfig.xml') and parseCommandLineArguments():
    global ProductToBuild
    global ProductElements
    global ProductsRoot

    elementsToBuild = ProductsRoot.findall('./product/[@id="'+ProductToBuild+'"]')

    for elementToBuild in elementsToBuild:
        checkOutAndBuildProduct(elementToBuild)
