(use-modules (zig) (ahotts) ;; These come from my own packages
             (ice-9 rdelim)
             (ice-9 popen)
             (guix gexp)
             (guix packages)
             (guix git-download)
             (guix build utils)
             (guix build-system zig)
             (gnu packages audio)
             ((guix licenses) #:prefix license:))


(define %source-dir (getcwd))
(define %git-commit
  (read-line
    (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2 "  OPEN_READ)))
(define (discard-git path stat)
  (let* ((start (1+ (string-length %source-dir)) )
         (end   (+ 4 start)))
  (not (false-if-exception (equal? ".git" (substring path start end))))))

(define-public karkarkar
  (let ((version "0.0.1")
        (revision "0"))
   (package
    (name "karkarkar")
    (version (string-append version "-" revision "-" %git-commit))
    (source (local-file %source-dir
                        #:recursive? #t
                        #:select? discard-git))
    (build-system zig-build-system)
    (inputs (list ahotts openal))
    (arguments
      (list
        #:zig zig-0.11
        #:tests? #f
        #:phases #~(modify-phases %standard-phases (delete 'validate-runpath))))
    (synopsis "Listen to Twitch chat in Basque")
    (description "karkarkar reads your twitch chat out loud in Basque so you
can be the coolest streamer in the land of the bertso and the rock lifting.")
    (home-page "https://ekaitz-zarraga.itch.io/karkarkar")
    (license license:gpl3+))))

karkarkar
