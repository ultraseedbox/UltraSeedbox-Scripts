import os
import time
from datetime import datetime
import requests
# Modules import

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
rtorrent_log_file = '{}/scripts/app_monitor/rtorrent.txt'.format(work_dir)
docker_log_file = '{}/scripts/app_monitor/docker_apps.txt'.format(work_dir)
Discord_WebHook_File = '{}/scripts/app_monitor/discord.txt'.format(work_dir)
Web_Hook_URL = ""
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
    
    def rtorrent_monitor(self, Web_Hook_URL):
        Pid = os.system('pgrep rtorrent')
        Pid = int(Pid)

        if Pid == 256:  # Pid is 256 when os.system doesn't give O/P for Linux
            os.system("app-rtorrent restart")  # restart app
            data = {
                "content": f'**rtorrent application was down and has been restarted by script** :)'}
            response = requests.post(Web_Hook_URL, json=data)
        else:
            pass
        time.sleep(2)
        Pid2 = os.system('pgrep rtorrent')
        Pid2 = int(Pid2)

        if Pid2 == 256:  # no effect of restart so time to repair
            os.system("app-rtorrent repair")
            data = {
                "content": f'**rtorrent application was down and has been repair by script** :)'}
            response = requests.post(Web_Hook_URL, json=data)

        else:
            pass
        time.sleep(2)

        final_pid = os.system('pgrep rtorrent')

        if final_pid == 256:  # restart or repair comands doesn't work
            data = {"content": f' **Script is unable to FIX your rTorrent so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php**'}
            response = requests.post(Web_Hook_URL, json=data)
        else:
            pass

    def docker_app(self, apps, Web_Hook_URL):
        for i in apps:
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} upgrade".format(i))
                data = {
                    "content": f'**Your {i} application was down and has been restarted by script** :)'}
                response = requests.post(Web_Hook_URL, json=data)
            else:
                pass
            time.sleep(180)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                data = {"content": f"**Script is unable to FIX your {i} so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php**"}
                response = requests.post(Web_Hook_URL, json=data)

    def create_app_list(self):
        app_list = input(
            "Please enter all applications you want to monitor with a single space in between(for example sonarr radarr lidarr):").split()
        return app_list
    
    def write_applist(self, app_list):
        with open(apps_file, '+w') as f:
            for i in app_list:
                f.write(i + '\n')
        f.close()

    def Discord_Notifications_Accepter(self):
        Web_Url = input("Please enter your Discord Web Hook Url Here:")
        with open(Discord_WebHook_File, '+w') as f:
            f.write(Web_Url)
        f.close()

    def Discord_WebHook_Reader(self):
        with open(Discord_WebHook_File, 'r') as f:
            return f.read()

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

    def torrent_client_fixing(self, list1, Web_Hook_URL):
        for i in list1:
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} restart".format(i))
                data = {
                    "content": f'Your {i} application was down and has been restarted by script** :)'}
                response = requests.post(Web_Hook_URL, json=data)
            else:
                pass
            time.sleep(2)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                os.system("app-{} repair".format(i))
                data = {
                    "content": f'**Your {i} application was down and has been restarted by script** :)'}
                response = requests.post(Web_Hook_URL, json=data)
            time.sleep(2)
            status = os.popen("ps aux | grep -i {}".format(i)).read()
            count = len(status.splitlines())
            if count <= 2:
                data = {"content": f"**Script is unable to FIX your {i} so please open a support ticket from here - https://my.ultraseedbox.com/submitticket.php**"}
                response = requests.post(Web_Hook_URL, json=data)


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
        monitor.Discord_Notifications_Accepter()
        os.system("clear")
    elif 'rtorrent' in monitor_app_list:
        Web_Hook_URL = monitor.Discord_WebHook_Reader()
        monitor.Webserver_Shinobi()
        monitor.rtorrent_monitor(Web_Hook_URL)
        monitor_app_list.remove('rtorrent')
        s = monitor.torrent_client_checker(
            monitor_app_list, torrent_client_list)
        monitor.torrent_client_fixing(s, Web_Hook_URL)
        [monitor_app_list.remove(y) for y in s]
        monitor.docker_app(monitor_app_list, Web_Hook_URL)
        os.system("clear")
    else:
        monitor_app_list = monitor.read_list()
        Web_Hook_URL = monitor.Discord_WebHook_Reader()
        monitor.Webserver_Shinobi()
        s = monitor.torrent_client_checker(
            monitor_app_list, torrent_client_list)
        monitor.torrent_client_fixing(s, Web_Hook_URL)
        [monitor_app_list.remove(y) for y in s]
        monitor.docker_app(monitor_app_list, Web_Hook_URL)
        os.system("clear")
