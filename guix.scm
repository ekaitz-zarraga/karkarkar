(use-modules (zig)
             (ice-9 rdelim)
             (ice-9 popen)
             (guix gexp)
             (guix packages)
             (guix git-download)
             (guix build utils)
             (guix build-system zig)
             (gnu packages audio)
             (gnu packages imagemagick)
             (gnu packages inkscape)
             ((guix licenses) #:prefix license:))


(define %source-dir (getcwd))
(define %git-commit
  (read-line
    (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2 "  OPEN_READ)))
(define (discard-git path stat)
  (let* ((start (1+ (string-length %source-dir)) )
         (end   (+ 4 start)))
  (not (false-if-exception (equal? ".git" (substring path start end))))))


(let ((version "0.0.1")
      (revision "0"))
   (package
    (name "karkarkar")
    (version (string-append version "-" revision "-" %git-commit))
    (source (local-file %source-dir
                        #:recursive? #t
                        #:select? discard-git))
    (build-system zig-build-system)
    (native-inputs (list imagemagick inkscape))
    (inputs (list openal))
    (arguments
      (list
        #:zig zig-0.11
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (delete 'validate-runpath)
            (add-before 'install 'install-data
              (lambda _
                (mkdir-p (string-append #$output "/share/AhoTTS"))
                (copy-recursively "AhoTTS/data_tts" (string-append #$output "/share/AhoTTS"))))
            (add-before 'install 'prepare-desktop
              (lambda _
                (substitute* "linux/karkarkar.desktop"
                  (("Exec=.*") (string-append "Exec=" #$output "/bin/karkarkar ekaitzza")))
                (mkdir-p (string-append #$output "/share/icons/hicolor/scalable/apps/"))
                (copy-file "icons/karkarkar.svg" (string-append #$output "/share/icons/hicolor/scalable/apps/karkarkar.svg"))
                (copy-file "icons/karkarkar.svg" (string-append #$output "/share/icons/hicolor/scalable/apps/karkarkar-symbolic.svg"))
                (mkdir-p (string-append #$output "/share/applications/"))
                (copy-file "linux/karkarkar.desktop" (string-append #$output "/share/applications/karkarkar.desktop")))))))
    (synopsis "Listen to Twitch chat in Basque")
    (description "karkarkar reads your twitch chat out loud in Basque so you
can be the coolest streamer in the land of the bertso and the rock lifting.")
    (home-page "https://ekaitz-zarraga.itch.io/karkarkar")
    (license license:gpl3+)))
