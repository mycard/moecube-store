/** Function: getPosTopAccordingToWindowBounds
 * Fetches the window height and element height
 * and checks if specified position + element height is bigger
 * than the window height.
 *
 * If this evaluates to true, the position gets substracted by the element height.
 *
 * Parameters:
 *   (jQuery.Element) elem - Element to position
 *   (Integer) pos - Position top
 *
 * Returns:
 *   Object containing `px` (calculated position in pixel) and `alignment` (alignment of the element in relation to pos, either 'top' or 'bottom')
 */
Candy.Util.getPosTopAccordingToWindowBounds = function(elem, pos) {

    var windowHeight = $(document).height(),
        elemHeight   = elem.outerHeight(),
        marginDiff = elemHeight - elem.outerHeight(true),
        backgroundPositionAlignment = 'top';

    pos -= relative = $('#candy').offset().top
    if (pos + elemHeight >= windowHeight - relative) {
        pos -= elemHeight - marginDiff;
        backgroundPositionAlignment = 'bottom';
    }

    return { px: pos, backgroundPositionAlignment: backgroundPositionAlignment };
};