# Modules import
import os
import sys
from subprocess import check_output, check_call

"""
Path definded for the directories
"""

path = os.getcwd()  # homex/username
apps_path = path + '/.apps'
config_path = path + '/.config'
files_path = path + '/files'
downloads_path = path + '/downloads'
music_path = path + '/media/Music'
Movie_path = path + '/media/Movies'
tv_path = path + '/media/"TV Shows"'
book_path = path + '/media/Books'
backup_path = path + '/.apps/backup/*'
rutorrent_plugin = path + '/www/rutorrent'
bin_path = path + '/bin'
systemd_app = config_path + '/systemd/user/'
media = path + '/media'
""""""


def package_install(package):
    FNULL = open(os.devnull, 'w')
    check_call([sys.executable, "-m", "pip", "install", package], stdout=FNULL)


class FactorReset():
    """
    Will unmount a single rclone mount

    """

    def unmount_rclone(self):
        grep_path = os.popen("mount | grep $USER").read()
        if grep_path == "":
            pass
        else:
            rclone_path = grep_path.split()
            rclone_path = rclone_path[2]
            os.system("systemctl --user stop rclone-vfs")
            os.system("systemctl --user stop mergerfs")
            os.system("fusermount -zu {}".format(rclone_path))
            os.system("killall rclone")

    """
    This function removes all directories except one mentioned in remove-dir array below
    """

    def Remove_Extra_directory(self, path):
        main_dir = []
        second_round = []
        remove_dir = ['media', 'files', 'downloads', '.bashrc', '.bash_history', '.bash_logout', 'watch', '.wget-hsts', '.config',
                      '.profile', 'www', 'bin', '.apps', '.ssh']  # these directories will not get removed
        listed_dir = os.listdir(path)
        for lis in listed_dir:
            main_dir.append(lis)
        final_dir = list(set(main_dir).difference(remove_dir))
        for i in final_dir:
            os.system("rm -rf {}".format(i))
        listed_dir = os.listdir(path)
        for lis in listed_dir:
            second_round.append(lis)
        second_round_dir = list(set(second_round).difference(remove_dir))
        for i in second_round_dir:
            os.system("rm -rf '{}'".format(i))

    """
    This function will uninstall all applications and clear .apps 
    """

    def uninstall_apps_directory(self, path):
        remove_apps = ['backup', 'nginx']
        all_apps = os.listdir(path)
        delete_apps = list(set(all_apps).difference(remove_apps))
        for i in delete_apps:
            os.system("rm -rf" + " " + apps_path + "/" + i)
        for i in delete_apps:
            os.system("app-{} uninstall ".format(i))

    """
    This function uninstall all the torrent clients and clear .config directory except imporant directories
    
    """

    def delete_config(self, path):
        remove_config = ['systemd']
        all_configs = os.listdir(path)
        delete_config = list(set(all_configs).difference(remove_config))
        os.system("app-rtorrent uninstall --full-delete")
        os.system("app-deluge uninstall --full-delete")
        os.system("app-transmission uninstall --full-delete")
        os.system("app-qbittorrent uninstall --full-delete")
        os.system("rm -rf www/rutorrent")
        #os.system("rm -rf {}".format(backup_path))
        os.system("rm -rf {}".format(rutorrent_plugin))
        for i in delete_config:
            os.system("rm -rf" + " " + config_path + "/" + i)

    """
    This function delete data from all pre-exisiting main directories
    """

    def delete_Data_from_maindirectory(self, path1, path2, path3, path4, files_path, downloads_path):
        os.system("rm -rf {}".format(path1 + "/*"))
        os.system("rm -rf {}".format(path2 + "/*"))
        os.system("rm -rf {}".format(path3 + "/*"))
        os.system("rm -rf {}".format(path4 + "/*"))
        os.system("rm -rf {}".format(files_path + "/*"))
        os.system("rm -rf {}".format(downloads_path + "/*"))

    """
    Clears Bin directory from user slot
    """

    def ClearBin(self, files_path):
        avoid = ['nginx']
        all_bin_dir = os.listdir(files_path)
        delete_bin_dir = list(set(all_bin_dir).difference(avoid))
        for i in delete_bin_dir:
            os.system("rm -rf" + " " + files_path + "/" + i)

    """
    Will stop all systemd related application or process and than will remove them except important one
    """

    def Stop_Systemd_app(self, path):
        dir_list = []
        not_remove_systemd_app = ['default.target.wants', 'nginx.service']
        list_dir = os.listdir(path)
        for i in list_dir:
            dir_list.append(i)
        final_list = list(set(dir_list).difference(not_remove_systemd_app))
        if len(final_list) == 0:
            pass
        else:
            for s in final_list:
                os.system("systemctl --user stop {}".format(s))
                os.system("rm -rf" + " " + path + "/" + i)

        os.system("systemctl --user daemon-reload")
        os.system("systemctl --user reset-failed")

    """
    Install a fresh nginx on user service
    """

    def Finalfix(self):
        os.system("app-nginx uninstall && app-nginx install && app-nginx restart")
        os.system("clear")
    """
    Install fresh .profile and .bashrc and delete old files
    """

    def Fresh_Bash_install(self):
        os.system("rm -rf .bashrc")
        os.system("rm -rf .profile")
        os.system("cp /etc/skel/.profile ~/")
        os.system("cp /etc/skel/.bashrc ~/")
        check_output("source .bashrc",   shell=True, executable="/bin/bash")
        check_output("source .profile",   shell=True, executable="/bin/bash")

    """
    this function clears crontab
    """

    def clear_corntab(self):
        os.system("crontab -r")
    """
    Delete custom directories from media directory
    
    """

    def Delete_Custom_media_files(self, path):
        dir_list = []
        impt_dir = ['TV Shows', 'Movies', 'Music', 'Books']
        all_dir = os.listdir(path)
        for i in all_dir:
            dir_list.append(i)
        delete_dir = list(set(dir_list).difference(impt_dir))
        for i in delete_dir:
            os.system("rm -rf" + " " + path + "/" + i)


reset = FactorReset()

if __name__ == '__main__':
    print("\033[91m" + "Disclaimer: This script is unofficial and USB staff will not support any issues with it" + "\033[0m")
    s = input("Are you sure you want to delete all your data and applications config because once script is executed your data will be deleted forever we won't be able to get back your data ? (yes/no)")
    
    if s == "yes" or s == "Yes" or s == "YES":
        confirmation = input("Please type 'confirm' to run the script:")
        if confirmation == "confirm":
            print("Choose the option from the list below.\n")
            print("1. Complete reset delete all data and config. \n")
            print("2. Delete all extra folders and files. \n")
            print("3. Uninstall all applications and their config but don't delete data. \n")
            print("4. Delete data from default directories. \n")
            choice = input("Please enter your choice: ")
            if choice == "1":

                reset.unmount_rclone()
                reset.Remove_Extra_directory(path)
                reset.uninstall_apps_directory(apps_path)
                reset.delete_config(config_path)
                reset.delete_Data_from_maindirectory(
                    Movie_path, tv_path, music_path, book_path, files_path, downloads_path)
                reset.Delete_Custom_media_files(media)
                reset.ClearBin(bin_path)
                reset.Stop_Systemd_app(systemd_app)
                reset.Fresh_Bash_install()
                reset.clear_corntab()
                reset.Finalfix()

                print("Cleanup process has been completed")
            if choice == "3":

                reset.uninstall_apps_directory(apps_path)
                reset.delete_config(config_path)
                reset.Stop_Systemd_app(systemd_app)
                reset.ClearBin(bin_path)
                reset.Fresh_Bash_install
                reset.clear_corntab()
                reset.Finalfix()

                print("Cleanup process has been completed")
            if choice == "2":

                reset.Remove_Extra_directory(path)
                reset.Finalfix()

                print("Cleanup process has been completed")
            if choice == "4":

                reset.delete_Data_from_maindirectory(
                    Movie_path, tv_path, music_path, book_path, files_path, downloads_path)
                reset.Delete_Custom_media_files(media)
                reset.Finalfix()

                print("Cleanup process has been completed")
        else:
            print("Script has been stoped.")
    elif s == "no" or s == "NO" or s == "No":
        print("Factor Reset has been stopped,All your data is safe")
        exit()
    else:
        print("Please run the script again and choose valid option.")
