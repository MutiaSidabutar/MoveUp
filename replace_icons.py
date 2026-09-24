import os
import re

ICON_MAP = {
    'LucideIcons.activity': 'Icons.timeline',
    'LucideIcons.mail': 'Icons.mail_outline',
    'LucideIcons.lock': 'Icons.lock_outline',
    'LucideIcons.home': 'Icons.home_outlined',
    'LucideIcons.clock': 'Icons.access_time',
    'LucideIcons.barChart2': 'Icons.bar_chart',
    'LucideIcons.user': 'Icons.person_outline',
    'LucideIcons.plus': 'Icons.add',
    'LucideIcons.flame': 'Icons.local_fire_department_outlined',
    'LucideIcons.timer': 'Icons.timer_outlined',
    'LucideIcons.footprints': 'Icons.directions_run',
    'LucideIcons.personStanding': 'Icons.directions_walk',
    'LucideIcons.bike': 'Icons.directions_bike',
    'LucideIcons.dumbbell': 'Icons.fitness_center',
    'LucideIcons.navigation': 'Icons.navigation_outlined',
    'LucideIcons.arrowLeft': 'Icons.arrow_back',
    'LucideIcons.pause': 'Icons.pause',
    'LucideIcons.filter': 'Icons.filter_alt_outlined',
    'LucideIcons.map': 'Icons.map_outlined',
    'LucideIcons.target': 'Icons.track_changes',
    'LucideIcons.bell': 'Icons.notifications_none',
    'LucideIcons.shield': 'Icons.security',
    'LucideIcons.logOut': 'Icons.logout',
    'LucideIcons.chevronRight': 'Icons.chevron_right',
    'LucideIcons.inbox': 'Icons.inbox',
}

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove the import
    content = re.sub(r"import 'package:lucide_icons/lucide_icons.dart';\n?", "", content)
    
    # Replace icons
    for lucide_icon, material_icon in ICON_MAP.items():
        content = content.replace(lucide_icon, material_icon)
        
    # Generic catch-all just in case I missed some
    content = re.sub(r"LucideIcons\.([a-zA-Z0-9_]+)", "Icons.star", content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    base_dir = r"c:\Users\Lenovo\program\flut_ter\moveup\lib"
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath)

if __name__ == "__main__":
    main()
