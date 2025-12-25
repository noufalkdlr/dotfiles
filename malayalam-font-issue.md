## 1. Install noto sans malayalam fonts


## 2. Create 64.mal.conf
```bash
sudo nano /etc/fonts/conf.d/64-mal.conf
```


## 3. Paste this code to 64-mal.conf

```bash
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <alias>
   <family>sans-serif</family>
   <prefer>
     <family>Noto Sans Malayalam</family>
   </prefer>
 </alias>

 <alias>
   <family>serif</family>
   <prefer>
     <family>Noto Serif Malayalam</family>
   </prefer>
 </alias>
</fontconfig>
```

## 4. Clear fc cache
```bash
fc-cache -fv
```
