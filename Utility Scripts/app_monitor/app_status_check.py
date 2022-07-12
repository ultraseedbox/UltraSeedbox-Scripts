import os
import time
from datetime import datetime
"""
Data and time to store restart time of application
"""
now = datetime.now()
current_time = now.strftime("%H:%M:%S")
"""
Variable for location log files
"""
work_dir = os.getcwd()
apps_file = '{}/scripts/app_monitor/apps.txt'.format(work_dir)
monitor_app_list = []
rtorrent_log_file = '{}/scripts/app_monitor/torrentapps.txt'.format(work_dir)
docker_log_file = '{}/scripts/app_monitor/docker_apps.txt'.format(work_dir)
torrent_client_list = ['deluge', 'transmission', 'qbittorrent', 'rtorrent']

"""
List of all application provide by us
"""
all_apps = ['airsonic', 'couchpotato', 'jackett', 'medusa', 'ombi', 'pydio', 'radarr', 'resilio', 'transmission', 'deluge',
            'jdownloader2', 'mylar3', 'openvpn', 'pyload', 'rapidleech', 'rtorrent', 'ubooquity', 'autodl', 'deluge', 
            'jellyfin', 'nextcloud', 'overseerr', 'rutorrent', 'sonarr', 'znc', 'bazarr', 'emby', 'lazylibrarian', 'plex', 'rapidleech',
            'sabnzbd', 'syncthing', 'btsync', 'filebot', 'lidarr', 'nzbget', 'readarr', 'sickbeard', 'tautulli',
            'filebrowser', 'mariadb', 'nzbhydra2', 'prowlarr', 'qbittorrent', 'requestrr', 'sickchill', 'thelounge']

"""
Main function is defined below
"""


class app_monitor():
    def InputValidation(self,lst1,lst2):
        check = all(item in lst1 for item in lst2)
        return check
    
    def rtorrent_monitor(self):
        Pid = os.system('pgrep rtorrent')
        Pid = int(Pid)

        if Pid == 256:  # Pid is 256 when os.system doesn't give O/P for Linux
            os.system("app-rtorrent restart")  # restart app
            with open(rtorrent_log_file, "a") as f:
                f.write("\n\nTIME: "+current_time+"\n")
                f.write('rTorrent was down and has been RESTARTED')
        else:
            pass
        time.sleep(2)
        Pid2 = os.system('pgrep rtorrent')
        Pid2 = int(Pid2)

        if Pid2 == 256:  # no effect of restart so time to repair
            os.system("app-rtorrent repair")
            with open(rtorrent_log_file, "a") as f:
                f.write("\nTIME:"+current_time+"\n")
                f.write('Restart failed so trying to REPAIR now')

        else:
            pass
        time.sleep(2)

        final_pid = os.system('pgrep rtorrent')

        if final_pid == 256:  # restart or repair comands doesn't work
            with open(rtorrent_log_file, "a") as f:
                f.write("\nTIME:"+current_time+"\n")
                f.write("\nScript is unable to FIX your rTorrent so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php\n")

        else:
            pass

    def docker_app(self, apps):
        for i in apps:
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} upgrade".format(i))
                with open(docker_log_file, "a") as f:
                    f.write("\nTIME: "+current_time+"\n")
                    f.write(f'{i} was down and has been RESTARTED')
                    os.system("clear")
            else:
                pass
            time.sleep(180)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                with open(docker_log_file, "a") as f:
                    f.write(
                        f"\nScript is unable to FIX your {i} so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php\n")

    def create_app_list(self):
            app_list = input(
            "Please enter all applications you want to monitor with a single space in between(for example sonarr radarr lidarr):").split()
            return app_list
    
    def write_applist(self, app_list):
        with open(apps_file, '+w') as f:
            for i in app_list:
                f.write(i + '\n')
        f.close()

    def read_list(self):
        with open(apps_file, 'r') as f:
            s = f.readlines()
        monitor_app_list = [x.strip() for x in s]
        return monitor_app_list

    def torrent_client_checker(self, list1, list2):
        list1 = set(list1)
        list2 = set(list2)
        list3 = list1.intersection(list2)
        return list(list3)
    
    def Webserver_Shinobi(self):
        status = os.popen("ps aux | grep -i nginx")
        count = len(status.readlines())
        if count <= 2:
                os.system("app-nginx restart")
        

    def torrent_client_fixing(self, list1):
        for i in list1:
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} restart".format(i))
                with open(rtorrent_log_file, "a") as f:
                    f.write("\nTIME: "+current_time+"\n")
                    f.write(f'{i} was down and has been RESTARTED')
                    os.system("clear")
            else:
                pass
            time.sleep(2)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} repair".format(i))
                with open(rtorrent_log_file, "a") as f:
                    f.write("\nTIME: "+current_time+"\n")
                    f.write(f'{i} was down and has been repair')
                    os.system("clear")
            time.sleep(2)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                with open(rtorrent_log_file, "a") as f:
                    f.write(
                        f"\nScript is unable to FIX your {i} so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php\n")


monitor = app_monitor()
if __name__ == '__main__':
    check = os.path.exists(apps_file)
    if check == False:
        app_list = monitor.create_app_list()
        while True:
            if monitor.InputValidation(all_apps,app_list):
                break
            else:
                print("Please check spelling of applications name\n")
                app_list = monitor.create_app_list()
        monitor.write_applist(app_list)
        print('Logs will be saved, now run',
              '\033[91m' + '"cat ~/scripts/app_monitor/docker_apps.txt  & cat ~/scripts/app_monitor/rtorrent.txt"' + '\033[0m', 'to print them!')
        time.sleep(5)
        os.system("clear")
    elif 'rtorrent' in monitor_app_list:
        monitor. Webserver_Shinobi()
        monitor.rtorrent_monitor()
        monitor_app_list.remove('rtorrent')
        s = monitor.torrent_client_checker(
            monitor_app_list, torrent_client_list)
        monitor.torrent_client_fixing(s)
        [monitor_app_list.remove(y) for y in s]
        monitor.docker_app(monitor_app_list,)
        os.system("clear")

    else:
        monitor. Webserver_Shinobi()
        monitor_app_list = monitor.read_list()
        s = monitor.torrent_client_checker(
            monitor_app_list, torrent_client_list)
        monitor.torrent_client_fixing(s)
        [monitor_app_list.remove(y) for y in s]
        monitor.docker_app(monitor_app_list)
        os.system("clear")