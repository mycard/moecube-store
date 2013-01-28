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

    if (pos + elemHeight >= windowHeight) {
        pos -= elemHeight - marginDiff;
        backgroundPositionAlignment = 'bottom';
    }
    pos -= $('#candy').offset().top
    return { px: pos, backgroundPositionAlignment: backgroundPositionAlignment };
};


    /** Function: update
     * Messages received get dispatched from this method.
     *
     * Parameters:
     *   (Candy.Core.Event) obj - Candy core event object
     *   (Object) args - {message, roomJid}
     */
    Candy.View.Observer.Message.update = function(obj, args) {
        if(args.message.type === 'subject') {
            if (!Candy.View.Pane.Chat.rooms[args.roomJid]) {
                Candy.View.Pane.Room.init(args.roomJid, args.message.name);
                Candy.View.Pane.Room.show(args.roomJid);
            }
            Candy.View.Pane.Room.setSubject(args.roomJid, args.message.body);
        } else if(args.message.type === 'info') {
            Candy.View.Pane.Chat.infoMessage(args.roomJid, args.message.body);
        } else {
            // Initialize room if it's a message for a new private user chat
            if(args.message.isNoConferenceRoomJid){
                args.roomJid = Strophe.getBareJidFromJid(args.roomJid)
            }
            if(args.message.type === 'chat' && !Candy.View.Pane.Chat.rooms[args.roomJid]) {
                Candy.View.Pane.PrivateRoom.open(args.roomJid, args.message.name, false, args.message.isNoConferenceRoomJid);
            }
            Candy.View.Pane.Message.show(args.roomJid, args.message.name, args.message.body, args.timestamp);
        }
    }