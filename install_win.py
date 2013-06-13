import xml.dom.minidom
import shutil
import os
import os.path as op

moduleName = "SmithMagic"
moduleDmName = "ExiTeD_" + moduleName + ".dm"
moduleSwfName = moduleName + ".swf"
moduleXmlName = "xml"
moduleCssName = "css"

srcPath = "."
dstPath = op.normpath(op.join(os.environ['PROGRAMFILES(X86)'], "Dofus2Beta/app/ui", moduleName))

shutil.copyfile(op.normpath(op.join(srcPath, moduleDmName)), op.normpath(op.join(dstPath, moduleDmName)))
shutil.copyfile(op.normpath(op.join(srcPath, moduleSwfName)), op.normpath(op.join(dstPath, moduleSwfName)))
shutil.rmtree(op.normpath(op.join(dstPath, moduleXmlName)), 1)
shutil.copytree(op.normpath(op.join(srcPath, moduleXmlName)), op.normpath(op.join(dstPath, moduleXmlName)))
shutil.rmtree(op.normpath(op.join(dstPath, moduleCssName)), 1)
shutil.copytree(op.normpath(op.join(srcPath, moduleCssName)), op.normpath(op.join(dstPath, moduleCssName)))