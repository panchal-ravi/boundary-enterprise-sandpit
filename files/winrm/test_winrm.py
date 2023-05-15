import winrm
import os

WIN_USER = os.getenv('WIN_USER')
WIN_PASSWORD = os.getenv('WIN_PASSWORD')

s = winrm.Session('localhost', auth=(WIN_USER, WIN_PASSWORD))
r = s.run_cmd('ipconfig', ['/all']);
# r = s.run_cmd('hostname', []);

print(r.status_code)
print(r.std_out.decode('utf-8'))
