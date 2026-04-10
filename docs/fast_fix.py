import sys

file_path = r'c:\Users\ADMIN\Desktop\Aarogya Sathi\docs\Aarogya_Sathi_Presentation_Preview.html'
try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Fix 'interactivity'
    content = content.replace('interactivity:inert;', '')
    content = content.replace('interactivity:auto;', '')

    # 2. Fix 'color-adjust'
    content = content.replace('color-adjust:exact!important;', '')

    # 3. Fix background-clip
    content = content.replace('-webkit-background-clip:text;', '-webkit-background-clip:text;background-clip:text;')

    # 4. Fix inline style custom properties lacking quotes that break IDE parsers.
    
    def quote_style(style_attr):
        for key in ['--header', '--footer', '--class', '--theme', '--style']:
            key_colon = key + ':'
            if key_colon in style_attr:
                start_idx = style_attr.find(key_colon) + len(key_colon)
                end_idx = style_attr.find(';', start_idx)
                if end_idx == -1: end_idx = len(style_attr)
                val = style_attr[start_idx:end_idx].strip()
                if not (val.startswith(\"'\") and val.endswith(\"'\")):
                    new_val = \"'\" + val.replace(\"'\", \"\\'\") + \"'\"
                    style_attr = style_attr[:start_idx] + new_val + style_attr[end_idx:]
        
        style_attr = style_attr.replace('\\n', '')
        return style_attr

    # Split by the known prefix of the problematic style attribute
    prefix = 'style=\"--paginate:true;'
    parts = content.split(prefix)
    
    if len(parts) > 1:
        new_content = parts[0]
        for i in range(1, len(parts)):
            end_idx = parts[i].find('\"')
            if end_idx != -1:
                inner_style = '--paginate:true;' + parts[i][:end_idx]
                fixed_inner = quote_style(inner_style)
                new_content += 'style=\"' + fixed_inner + '\"' + parts[i][end_idx+1:]
            else:
                new_content += prefix + parts[i]
        
        content = new_content

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(\"Successfully patched HTML.\")
except Exception as e:
    print(f\"Error: {e}\")
    sys.exit(1)
