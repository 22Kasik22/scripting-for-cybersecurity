#!/bin/bash
echo "Directories in the collection:"
find case -type d
echo ""
echo "Log files:"
ls case/logs
echo ""
echo "Size of the collection:"
du -sh case
echo "Done."
